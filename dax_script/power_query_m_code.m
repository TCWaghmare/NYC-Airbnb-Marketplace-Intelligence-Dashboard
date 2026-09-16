/*
===============================================================================
Power Query M Script: gold.dim_host Table Transformation
===============================================================================
Purpose:
    Cleans and enriches the host dimension table with descriptive columns
    (Superhost status, Identity verification status, Host portfolio category).
    Removes duplicates and reorders columns for consistency.
===============================================================================
*/

let
    // Connect to SQL Server database and load gold.dim_host table
    Source = Sql.Database("LAPTOP-T0MB2016\SQLEXPRESS", "NYC_Airbnb_DW"),
    gold_dim_host = Source{[Schema="gold",Item="dim_host"]}[Data],

    // Add a descriptive column for Superhost status
    #"Added Custom" = Table.AddColumn(gold_dim_host, "Superhost Status", each 
        if [IsSuperhost] = 0 then "No" 
        else if [IsSuperhost] = 1 then "Yes" 
        else "Unknown"),

    // Reorder columns to place Superhost Status next to IsSuperhost
    #"Reordered Columns" = Table.ReorderColumns(#"Added Custom",
        {"ListingKey", "HostID", "HostName", "IsSuperhost", "Superhost Status", 
         "IsIdentityVerified", "TotalListings", "ActiveListings", 
         "EntireHomeListings", "PrivateRoomListings", "SharedRoomListings", 
         "UserYears", "UserMonths", "TotalUserMonths", 
         "HostYears", "HostMonths", "TotalHostMonths"}),

    // Add a descriptive column for Identity Verification status
    #"Added Custom1" = Table.AddColumn(#"Reordered Columns", "Identity Verification Status", each 
        if [IsIdentityVerified] = 1 then "Verified"
        else if [IsIdentityVerified] = 0 then "Not Verified"
        else "N/A"),

    // Reorder columns to place Identity Verification Status next to IsIdentityVerified
    #"Reordered Columns1" = Table.ReorderColumns(#"Added Custom1",
        {"ListingKey", "HostID", "HostName", "IsSuperhost", "Superhost Status", 
         "IsIdentityVerified", "Identity Verification Status", "TotalListings", 
         "ActiveListings", "EntireHomeListings", "PrivateRoomListings", 
         "SharedRoomListings", "UserYears", "UserMonths", "TotalUserMonths", 
         "HostYears", "HostMonths", "TotalHostMonths"}),

    // Add a temporary Unique Host column for deduplication
    #"Added Custom2" = Table.AddColumn(#"Reordered Columns1", "Unique Host", each [HostID]),

    // Remove duplicate hosts based on Unique Host and HostID
    #"Removed Duplicates" = Table.Distinct(#"Added Custom2", {"Unique Host"}),
    #"Removed Duplicates1" = Table.Distinct(#"Removed Duplicates", {"Unique Host"}),
    #"Removed Duplicates2" = Table.Distinct(#"Removed Duplicates1", {"HostID"}),

    // Drop the temporary Unique Host column
    #"Removed Columns" = Table.RemoveColumns(#"Removed Duplicates2",{"Unique Host"}),

    // Add a Host Portfolio category based on TotalListings
    #"Added Custom3" = Table.AddColumn(#"Removed Columns", "Host portfolio", each 
        if [TotalListings] = null then "N/A"
        else if [TotalListings] = 1 then "Single-Listing Host"
        else if [TotalListings] >= 2 and [TotalListings] <= 5 then "Small Portfolio"
        else if [TotalListings] >= 6 and [TotalListings] <= 20 then "Medium Portfolio"
        else if [TotalListings] >= 21 then "Large Portfolio"
        else "No Portfolio"),

    // Keep all rows (placeholder filter step)
    #"Filtered Rows" = Table.SelectRows(#"Added Custom3", each true),

    // Final reorder of columns for clean structure
    #"Reordered Columns2" = Table.ReorderColumns(#"Filtered Rows",
        {"ListingKey", "HostID", "HostName", "IsSuperhost", "Superhost Status", 
         "IsIdentityVerified", "Identity Verification Status", "TotalListings", 
         "Host portfolio", "ActiveListings", "EntireHomeListings", 
         "PrivateRoomListings", "SharedRoomListings", "UserYears", "UserMonths", 
         "TotalUserMonths", "HostYears", "HostMonths", "TotalHostMonths"})
in
    #"Reordered Columns2"
