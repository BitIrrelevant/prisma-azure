# the first 4 entries should be the same
#the storage account resource group where the flow logs will be storage
$flowlogrg = "PrismaCLD_RG_Logs"
#the storage account used by the flow logs
$flowlogsg = "primsacldlogsa"
#this is typically default value
$networkwatcherrg = "NetworkWatcherRG"
#location of your flow logs (eastus, southuk, etc)
$location = "southuk"
# these 2 will need to be updated per NSG
#Resouce group where the NSG located
$nsgrg = "RG-AG-UKS-COREAXON-PR"
#Name of the Network security Group
$nsgname = "NSG-AG-UKS-CORE-AXON"
#tags to be added to flowlogs at creation. quote both the name and value. 
#add more with a semicolon ; as a separator. Sample included
#values will NOT show in CLI, but do show in WebUI
$tags = @{"Location"="South UK"; "Status"="Production"}


$NW = Get-AzNetworkWatcher -ResourceGroupName $networkwatcherrg -Name NetworkWatcher_$location
# grab the flowlog sg info. we will extract the ID for flow log setup
$flowlogsginfo = Get-AzStorageAccount -ResourceGroupName $flowlogrg -Name $flowlogsg 
# Grab the NSGs info. We will extract the NSG ID for flow log setup
$nsginfo = Get-AzNetworkSecurityGroup -ResourceGroupName $nsgrg -Name $nsgname
# verifying we got the flowlogs storage group and the nsg info and can pull the ID
$flowlogsginfo.Id
$nsginfo.Id
# making a name for the flowlog
$flowlogname = -join("NetworkWatcher_", $location, "_", $nsgname, "_flowlogs")

# below should show no logging enabled
Get-AzNetworkWatcherFlowLogStatus -NetworkWatcher $NW -TargetResourceId $nsginfo.Id

# create the flow log
New-AzNetworkWatcherFlowLog -Location $location -Name $flowlogname -TargetResourceId $nsginfo.Id -StorageId $flowlogsginfo.Id -Enabled $true -FormatVersion 2 -EnableRetention $true -RetentionPolicyDays 15 -Tag $tags

# verify it exists
Get-AzNetworkWatcherFlowLog -Location $location -Name $flowlogname

# delete if desired
#Remove-AzNetworkWatcherFlowlog -Location $location -Name $flowlogname