# Estimating Defense Contract Overages and Termination Risks with Supervised Learning

## Overview/Synopsis
With an annual budget in excess of $500 Billion, the U.S. Department of Defense (DOD) is one of the single largest money-spenders in the world. Each year, they award billions of dollars in contracts to research, develop, build, procure, or otherwise produce materials and technology to promote the public defense. These contracts can take vastly different forms and terms, encompassing everything from next-generation weapon systems to replenishing office supplies.

Given the sheer scope and variety of these contacts, it can be difficult for those making procurement decisions to reliably know what new contracts are the best deals, and which have the highest risk. Using a record of completed DoD contracts from the past 16 years, we use a Random Forest model to see what combination of contract features (e.g. duration, cost, competitive bids) are the most powerful predictors for whether a given new contract will a) exceed its original budget (i.e. a raised cost ceiling), and/or b) be terminated before completion.


## Use
A new or proposed contract will be evaluated based on the conditions known at the time of selection, including proposed amount, number of competitive bids, type of work, the prime contractor, etc. Then, two separate Random Forest models (with the same features) that have each been trained on a set of fully completed contracts predict the likelihood that the new contract will fall into one of the two risk categories.

## Data Used
The data for this project originally come from the Federal Procurement Data System, available from USAspending.gov. These data consist of tens of millions of line items, recording every instance of an action on federal contracts: Starts, modifications, task orders, and terminations. The data are available from Fiscal Year 2000. New entries appear daily, but are not made publically available until 30 days after the contract award (90 days for DoD). For our analysis, the data will be aggregated to the contract level. Each contract will then have its own characteristics including:

* Prime Contractor Name and Details
* Contract Start Date and Projected Completion Date
* Contract Budget Amount (base and all options)
* Total amount spent on contract over its full run
* Contract pricing type (e.g. Fixed Price, Cost-based, Combination)
* Price and performance incentives associated with the contract
* Whether a contract was intended for a single purpose, or as a vehicle for multiple task
orders
* Whether a contract was made available for competitive bidding
* Number of offers received for the contract, if it was bid competitively
* Which component of DoD awarded the contract (e.g. Army, Navy, Air Force)
* Whether any of the contract performance took place outside the U.S.
* Whether the contract was for Products, Services, or R&D

To ensure that all data points are on a similar level of data completeness, we will only include in our analysis contracts that have already concluded, either by completion or cancellation. This will help to avoid the training uncertainty of "contracts that might go over budget but haven't yet."

## Usage
All analysis, from exploratory data analysis to model training and predictions, is contained within the file "Defense Contract Prediction.R"

Later versions may include additional code to directly query the raw database for more precise variable aggregation.

## Progress Log
* (April 2017) Identified data source
* (April 2017) Identified candidate dependent and independent variables
* (April 2017) Procured codebook descriptions for component variables
* (In progress) Narrowing dataset to population of key analysis
* (In progress) Recoded variables for more precision and detail
* (In progress) Model specification and training for supervised learning algorithm
* (TBD) Project results for test group to verify model predictive power
* (TBD) Analyze relative importance/predictive power of component variables
* (TBD) Produce report for model and results

## Credits
Project Team: Bryan Baird, Loren Lipsy, Tommie Thompson -- Georgetown University

Preliminary data processing based on the work of Greg Sanders at the Center for Strategic and International Studies

## License
Licensed under GNU General Public License v3.0