### A Pluto.jl notebook ###
# v0.12.20

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ 332dac9c-eaaa-11ea-0ba2-71960df3e69b
begin
	using Pkg
	Pkg.activate(".")
	Pkg.add("DataFrames")
	using CSV, DataFrames, Dates
	using Plots, PlutoUI
	plotly()
end

# ╔═╡ 7c1ae4f6-e520-11ea-21fe-c9ca8c946879
md"# Covid Data Explorer"

# ╔═╡ 01588df4-e543-11ea-2c3f-cbd0692fae17
md"Select Multiple Countries to Include in Plot:"

# ╔═╡ 1de1a642-e543-11ea-2bbf-798cc66e8251
md"Slide to Change Plot End Date:"

# ╔═╡ 6c93faa8-e495-11ea-337c-17d4ef2987e3
md"""
 ### Data Processing:
"""

# ╔═╡ 485ec478-e46e-11ea-2e64-d5f0fce53a55
url = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_global.csv"

# ╔═╡ aeb604be-e495-11ea-04b8-1714bf90c5c6
begin
	download(url, "temp.csv")
	data = CSV.read("temp.csv",DataFrame) |>
		df -> DataFrames.rename(df, 1 => "Province", 2 => "Country")
	rm("temp.csv")
end

# ╔═╡ c547edaa-e6c3-11ea-0aaf-d947e4b35954
data

# ╔═╡ 5a513b56-e51e-11ea-06f3-77da2cc35859
begin
	date_labels = names(data)[5:end];
	date_format = Dates.DateFormat("m/d/y")
	dates = Date.(date_labels, date_format) .+ Dates.Year(2000)
end

# ╔═╡ 80e9c0d4-e542-11ea-16d7-79ac439f210d
@bind dates_index Slider(1:length(dates), default = 40)

# ╔═╡ ede54040-e51d-11ea-2c18-276764865533
countries = unique(data[:, :Country])

# ╔═╡ 43859c78-e46f-11ea-3faf-4736e95c3123
@bind selected_countries MultiSelect(
	[ctry => ctry for ctry in countries],
	default = ["US", "Brazil", "China", "Italy", "India"])

# ╔═╡ c0ab7f52-e487-11ea-0ea1-bf41c0164efe
data_by_country = data |>
	df -> DataFrames.groupby(df, :Country) |>
	df -> DataFrames.combine(df, (date_labels .=> sum .=> date_labels))

# ╔═╡ f4e65194-eab2-11ea-24f3-d1e6005c7be4
#data_by_country

# ╔═╡ b2ef8cc0-e543-11ea-1937-97a3885f8421
md"### Per Country Helper Functions"

# ╔═╡ ec5c80da-e543-11ea-2b4c-d7a3705f5fe5
function make_first_plot()
	base_plot = plot(legend = false)
	xlabel!(base_plot, "Dates")
	ylabel!(base_plot, "Deaths")
	title!(base_plot, "Deaths Covid 19 Cases")
	
	base_plot
end

# ╔═╡ 99dd5ba0-e470-11ea-30ef-59db8fd89c12
function get_country_data(country)
	data_by_country |>
		df -> filter(:Country => val -> val == country, df) |>
		df -> df[1, 2:end]|>
		df -> convert(Vector, df)
end

# ╔═╡ b3235988-e539-11ea-2e44-37b53c7487ce
function add_plot!(target_plot, country, index)
	country_data = get_country_data(country)
	plot!(target_plot,
		dates[1:index], country_data[1:index],
		xticks    = dates[1:15:end],
		xrotation = 45,
		#label = country,
		lw = 3)
end

# ╔═╡ 5483a8fe-e48c-11ea-1d61-052ac9ffea8c
begin
	output_plot = make_first_plot()
	for country in selected_countries
		add_plot!(output_plot, country, dates_index)
	end
	output_plot
end

# ╔═╡ b8bddbdc-eab3-11ea-3bfe-e1f20ed6ea76
data_by_country |>
df -> df[df.Country .== "US", 2:end] |>
	df -> convert(Vector, df[1, :])

# ╔═╡ Cell order:
# ╟─7c1ae4f6-e520-11ea-21fe-c9ca8c946879
# ╟─01588df4-e543-11ea-2c3f-cbd0692fae17
# ╟─43859c78-e46f-11ea-3faf-4736e95c3123
# ╟─1de1a642-e543-11ea-2bbf-798cc66e8251
# ╟─80e9c0d4-e542-11ea-16d7-79ac439f210d
# ╟─5483a8fe-e48c-11ea-1d61-052ac9ffea8c
# ╟─6c93faa8-e495-11ea-337c-17d4ef2987e3
# ╠═332dac9c-eaaa-11ea-0ba2-71960df3e69b
# ╠═485ec478-e46e-11ea-2e64-d5f0fce53a55
# ╠═aeb604be-e495-11ea-04b8-1714bf90c5c6
# ╠═c547edaa-e6c3-11ea-0aaf-d947e4b35954
# ╠═5a513b56-e51e-11ea-06f3-77da2cc35859
# ╠═ede54040-e51d-11ea-2c18-276764865533
# ╠═c0ab7f52-e487-11ea-0ea1-bf41c0164efe
# ╠═f4e65194-eab2-11ea-24f3-d1e6005c7be4
# ╟─b2ef8cc0-e543-11ea-1937-97a3885f8421
# ╠═ec5c80da-e543-11ea-2b4c-d7a3705f5fe5
# ╠═b3235988-e539-11ea-2e44-37b53c7487ce
# ╠═99dd5ba0-e470-11ea-30ef-59db8fd89c12
# ╠═b8bddbdc-eab3-11ea-3bfe-e1f20ed6ea76
