#Pull AD properties from Useraccounts that are in a input CSV list and log to a output csv file
# Created by Deon van Zyl
Set-ExecutionPolicy RemoteSigned

$csvFile = "D:\users_list.csv"
$csvFile2 = "D:\users_ad_list.csv"
$table = Import-Csv $csvFile

Remove-Item -path $csvFile2

foreach ($row in $table) {
# The input CSV (csvfile) is expected to have the following columns $row.Site_URL,$row.Owner_Name,$row.Username
    try {
         # note businesscategory is a array of items and we are using the Username as the key to get the information
        $props1 = Get-ADUser -identity $row.Username -Properties division,businessCategory,Department | Select division,@{N="businessCategory";E={$_.businessCategory -join ","}},Department 
   #Export the full line to the CSV
        "" | select-object @{N="Site_URL"; E={$row.Site_URL}}, @{N="Owner_Name"; E={$row.Owner_Name}},@{N="Username"; E={$row.Username}},@{N="Branch"; E={$props1.division}}, @{N="Directorate"; E={$props1.businessCategory}}, @{N="Department"; E={$props1.Department}} | Export-CSV $csvFile2  -NoTypeInformation -Append -Encoding UTF8

    }catch{
        $errormsg = "Error with processing " + $row.Username + " for site $row.Site_URL"
        echo  "$errormsg" >> $csvFile2
        write-output $errormsg
    }

}
