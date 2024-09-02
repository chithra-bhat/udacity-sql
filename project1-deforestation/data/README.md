# Project 1: Deforestation

This project analyzes global deforestation data for ForestQuery, a non-profit dedicated to combat deforestation. The goal is to create a comprehensive report highlighting trends in forest area changes and regional impacts to guide strategic decisions and resource allocation.

### Steps to Complete

1. **Create a View called “forestation”** by joining all three tables - `forest_area`, `land_area`, and `regions` in the workspace.

2. **Join Criteria**:
   - The `forest_area` and `land_area` tables join on both `country_code` **AND** `year`.
   - The `regions` table joins these based on only `country_code`.

3. **In the ‘forestation’ View, Include the Following**:
   - All of the columns of the origin tables.
   - A new column that provides the percent of the land area that is designated as forest.

4. **Unit Conversion**:
   - Keep in mind that the column `forest_area_sqkm` in the `forest_area` table and the `land_area_sqmi` in the `land_area` table are in different units (square kilometers and square miles, respectively). So, an adjustment will need to be made in the calculation you write    (1 sq mi = 2.59 sq km).
