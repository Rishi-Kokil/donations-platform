// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract Donation {
    
    // Donation Campaigns run by various Organizations
    struct Campaign {
        address owner;
        string title;
        string description;
        uint256 target;
        uint256 deadline;
        uint256 amountCollected;
        string image;
        address[] donators;
        uint256[] donations;
        uint256[] milestones;  // Store milestone percentages
        uint256[] milestoneAmounts;  // Store amounts to release at each milestone
        bool[] milestoneReached;  // Track whether milestones are reached
    }

    mapping(uint256 => Campaign) public campaigns;
    uint256 public numberOfCampaigns = 0;

    // Function to create a new donation campaign
    function createCampaign(
        address _owner, 
        string memory _title, 
        string memory _description,
        uint256 _target, 
        uint256 _deadline, 
        string memory _image,
        uint256[] memory _milestones // Pass milestones as an array of percentages
    ) 
        public 
        returns (uint256) 
    {
        require(_milestones.length > 0, "At least one milestone must be set.");

        Campaign storage campaign = campaigns[numberOfCampaigns];

        require(_deadline > block.timestamp, "Deadline should be in the future.");

        campaign.owner = _owner;
        campaign.title = _title;
        campaign.description = _description;
        campaign.target = _target;
        campaign.deadline = _deadline;
        campaign.image = _image;

        // Initialize milestones
        for (uint i = 0; i < _milestones.length; i++) {
            campaign.milestones.push(_milestones[i]);
            campaign.milestoneAmounts.push((_target * _milestones[i]) / 100); // Calculate milestone amounts
            campaign.milestoneReached.push(false); // Initially, all milestones are not reached
        }

        numberOfCampaigns++;

        return numberOfCampaigns - 1;
    }

    // Function to donate to a specific campaign by ID
    function donateToCampaign(uint256 _id) public payable {
        uint256 amount = msg.value;
        Campaign storage campaign = campaigns[_id];

        campaign.donators.push(msg.sender);
        campaign.donations.push(amount);

        (bool sent, ) = payable(campaign.owner).call{value: amount}("");
        
        if (sent) {
            campaign.amountCollected += amount;
            checkMilestones(_id);  // Check if any milestones are reached after donation
        }
    }

    // Function to check and mark milestones as reached
    function checkMilestones(uint256 _id) internal {
        Campaign storage campaign = campaigns[_id];
        
        for (uint i = 0; i < campaign.milestones.length; i++) {
            if (!campaign.milestoneReached[i]) {
                if (campaign.amountCollected >= campaign.milestoneAmounts[i]) {
                    campaign.milestoneReached[i] = true;  // Mark milestone as reached
                    releaseFunds(_id, campaign.milestoneAmounts[i]);  // Release funds if milestone reached
                }
            }
        }
    }

    // Function to release funds to the owner when milestones are reached
    function releaseFunds(uint256 _id, uint256 _amount) internal {
        Campaign storage campaign = campaigns[_id];
        
        (bool sent, ) = payable(campaign.owner).call{value: _amount}("");
        require(sent, "Failed to send Ether");
    }

    // Function to get the list of donators and their donations for a specific campaign
    function getDonators(uint256 _id) 
        public 
        view 
        returns (address[] memory, uint256[] memory) 
    {
        return (campaigns[_id].donators, campaigns[_id].donations);
    }

    // Function to get all campaigns
    function getCampaigns() 
        public 
        view 
        returns (Campaign[] memory) 
    {
        Campaign[] memory allCampaigns = new Campaign[](numberOfCampaigns);
        for (uint i = 0; i < numberOfCampaigns; i++) {
            Campaign storage item = campaigns[i];
            allCampaigns[i] = item;
        }
        return allCampaigns;
    }
}
