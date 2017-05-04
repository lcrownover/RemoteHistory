# RemoteHistory
PowerShell wrapper for BrowsingHistoryView

http://www.nirsoft.net/utils/browsing_history_view.html

BrowsingHistoryView's full functionality is limited while running against a network system. My wrapper allows you to target a computer and it will gather the data as if it was run locally on their system.


Instructions

1. Clone or copy into your WindowsPowerShell\Modules folder
2. Import-Module RemoteHistory
3. Get-RemoteHistory 
    
    -ComputerName : Target computer
    
    -TargetUser : User account to collect data from. Leave blank for all users.
    
    -DaysBack : How many days back you want to search. Leave blank for 365 days.
    
4. You should have a .csv file on your desktop with the results.
