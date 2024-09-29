// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract Donation {
    
    // Donation Campaigns run by various Organizations
    // This Struct below holds all the necessary information of a Donation Campaign
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
    }

    // Mapping that stores all the campaigns
    mapping(uint256 => Campaign) public campaigns;
    uint256 public numberOfCampaigns = 0;

    // List of all the functions needed for our donations platform

    // Function to create a new donation campaign
    function createCampaign(
        address _owner, 
        string memory _title, 
        string memory _description,
        uint256 _target, 
        uint256 _deadline, 
        string memory _image
    ) 
        public 
        returns (uint256) 
    {
        // Access the campaign at the current index and create a reference
        Campaign storage campaign = campaigns[numberOfCampaigns];

        // Ensure the deadline is in the future
        require(_deadline > block.timestamp, "Deadline should be in the future.");

        // Assign values to the campaign
        campaign.owner = _owner;
        campaign.title = _title;
        campaign.description = _description;
        campaign.target = _target;
        campaign.deadline = _deadline;
        campaign.image = _image;

        // Increment the number of campaigns
        numberOfCampaigns++;

        // Return the index of the newly created campaign
        return numberOfCampaigns - 1;
    }

    // Function to donate to a specific campaign by ID
    function donateToCampaign(uint256 _id) public payable {
        uint256 amount = msg.value;  // The amount sent by the sender
        Campaign storage campaign = campaigns[_id];

        // Add the sender's address and donation amount to the campaign
        campaign.donators.push(msg.sender);
        campaign.donations.push(amount);

        // Transfer the donation to the campaign owner
        (bool sent, ) = payable(campaign.owner).call{value: amount}("");

        // If successful, update the total amount collected
        if (sent) {
            campaign.amountCollected += amount;
        }
    }

    // Function to get the list of donators and their donations for a specific campaign
    function getDonators(uint256 _id) 
        public 
        view 
        returns (address[] memory, uint256[] memory) 
    {
        // Return the list of donators and donations for the campaign
        return (campaigns[_id].donators, campaigns[_id].donations);
    }

    // Function to get all campaigns
    function getCampaigns() 
        public 
        view 
        returns (Campaign[] memory) 
    {
        // Create an array to hold all campaigns
        Campaign[] memory allCampaigns = new Campaign[](numberOfCampaigns);

        // Loop through all campaigns and add them to the array
        for (uint i = 0; i < numberOfCampaigns; i++) {
            Campaign storage item = campaigns[i];
            allCampaigns[i] = item;
        }

        // Return the array of campaigns
        return allCampaigns;
    }
}
