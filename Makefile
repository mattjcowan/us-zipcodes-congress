all: clean zccd.csv zccd_hud.csv

clean:
	mkdir -p raw
	rm -f zccd.csv
	rm -f zccd_hud.csv

zccd.csv: raw/natl_zccd_delim.txt  raw/zcta_county_rel_10.txt raw/state_fips.txt raw/zccd_updates.txt
	python merge_data.py

zccd_hud.csv: raw/hud_crosswalk.xlsx
	python hud_crosswalk.py

# MOST OF THESE FROM: 
//https://www.census.gov/geographies/reference-files/2010/geo/relationship-files.html

# Congressional districts by zip code tabulation area (ZCTA) national, comma delimited
# NB: does not include at-large districts for AK, DE, MT, ND, SD, VT, WY, PR or DC
# 2010 ZCTA to County Relationship File
# Explanation of the 2010 ZCTA to County Relationship File (http://www2.census.gov/geo/pdfs/maps-data/data/rel/explanation_zcta_county_rel_10.pdf?#)
# previous: https://www2.census.gov/geo/relfiles/cdsld16/natl/natl_zccd_delim.txt
raw/natl_zccd_delim.txt:
	curl "https://www2.census.gov/geo/relfiles/cdsld18/natl/natl_zccd_delim.txt" -k -o raw/natl_zccd_delim.txt

# inter-censal changes to congressional districts are released only for updated states
# necessary for CO, FL, MN, NC, PA, VA
raw/zccd_updates.txt:
	curl "https://www2.census.gov/geo/relfiles/cdsld18/08/zc_cd_delim_08.txt" -k -o raw/zc_cd_delim_08.txt
	curl "https://www2.census.gov/geo/relfiles/cdsld16/12/zc_cd_delim_12.txt" -k -o raw/zc_cd_delim_12.txt
	curl "https://www2.census.gov/geo/relfiles/cdsld18/27/zc_cd_delim_27.txt" -k -o raw/zc_cd_delim_27.txt
	curl "https://www2.census.gov/geo/relfiles/cdsld16/37/zc_cd_delim_37.txt" -k -o raw/zc_cd_delim_37.txt
	curl "https://www2.census.gov/geo/relfiles/cdsld18/42/zc_cd_delim_42.txt" -k -o raw/zc_cd_delim_42.txt
	curl "https://www2.census.gov/geo/relfiles/cdsld16/51/zc_cd_delim_51.txt" -k -o raw/zc_cd_delim_51.txt

# 2010 ZCTA to state & county
# TODO, try to find an updated version
raw/zcta_county_rel_10.txt:
	curl 'https://www2.census.gov/geo/docs/maps-data/data/rel/zcta_county_rel_10.txt' -k -o $@

# FIPS State/Territory codes to names
raw/state_fips.txt:
	curl 'https://www2.census.gov/geo/docs/reference/state.txt' -k -o $@

# HUD data from Q1 2020
# available only under USPS sublicense - see readme
raw/hud_crosswalk.xlsx:
	curl 'https://www.huduser.gov/portal/datasets/usps/ZIP_CD_032020.xlsx' -k -o $@

# test against previously released data from Sunlight Foundation
test: raw/old_sunlight_districts.csv
	python test.py

raw/old_sunlight_districts.csv:
	curl 'https://raw.githubusercontent.com/OpenSourceActivismTech/call-power/0ee10f026d2c0758e49a786b43b980c1c2d1d4c7/call_server/political_data/data/us_districts.csv' -k -o $@.download
	mv $@.download $@.raw
	echo 'zipcode,state,house_district' >> raw/old_sunlight_headers.txt
	cat raw/old_sunlight_headers.txt $@.raw > $@
	rm raw/old_sunlight_headers.txt $@.raw