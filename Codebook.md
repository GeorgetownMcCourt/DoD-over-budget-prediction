---
title: "DoD Over Budget Prediciton Codebook"
date: "April 4, 2017"
---

### CSIScontractID   
__label__   
A unique indentifier   

### FxCb   
__categorical__   
_levels:_ _"Fixed-Price" ; "Cost-Based" ; "Combination or Other"_   
The pricing mechanism of the contract.   

### Fee   
__categorical__   
_levels: "FFP or No Fee" ; "Combination or Other Fee" ; "Fixed Fee" ; "Incentive" ; "Award Fee"_   
Fees and incentives associated with the contract.  "Incentive" is a cost-sharing mechanism in which a contractor may keep some of the profit if they come in under budget, but must pay some of the overage if exceeding budget.  "Award" is a potential bonus fee for meeting some performance criteria.   

### IDV   
__categorical__   
_levels: "IDV" ; "Def/Pur"_   
Whether the contract is a task order (IDV) or an award (Def/Pur).   

### Comp   
__categorical__   
_levels: "Comp." ; "No Comp." ; "Unlabeled"_   
Whether the contract was bid competitively.   

### Who   
__categorical__   
_levels: "Other DoD" ; "Army" ; "Navy" ; "Air Force"_   
The DoD component that issued the contract.

### What   
__categorical__   
_levels: [1] "Other" ; "Electronics and Communications" ; "Aircraft and Drones" ; "Land Vehicles" ; "Weapons and Ammunition" ; "Facilities and Construction" ; "Ships & Submarines" ; "Missile and Space Systems" ; "Unlabeled"_   
What DoD bought.   

### Intl   
__categorical__   
_levels: "Just U.S." ; "Any International"_   
Whether any part of the contract had a place of performance outside the United States.

### PSR   
__categorical__   
_levels: "Products" ; "Services" ; "R&D"_   
High-level categorization of what DoD bought in the contract.   


### LowCeil   
__categorical__   
_levels: "[0,15k)" ; "[100k,1m)" ; "[15k,100k)" ; "[1m,30m)" ; "[30m+]"_   
The initial ceiling of the contract, segmented into range categories.   

### Ceil   
__categorical__   
_levels: "[0,15k)" ; "[100k,1m)" ; "[15k,100k)" ; "[1m,10m)" ; "[10m,75m)" ; "[75m+]"_    
The initial ceiling of the contract, segemented into range categories, with high-dollar contracts a little more broken out than in LowCeil.   

### Dur   
__categorical__   
_levels: "[0 months,~2 months)" ; "[~7 months-~1 year]" ; "(~1 year,~2 years]" ; "[~2 months,~7 months)" ; "(~2 years+]"_   
The anticipated maximum duration of a contract at time of award, segmented into ranges.

### SingleOffer   
__categorical__   
_levels: "Multi"  "Single"_   
Whether DoD received more than one offer on the contract.  "Single" includes both contracts that were not competitively bid and contracts that were competitively bid but only received one offer.   

### Offr   
__categorical__   
_levels: "2"   "3-4" ; "1"   "5+"_   
The number of offers DoD received for the contract, segmented into categories.   

### Soft   
__categorical__   
_levels: "Not Software Eng." ; "Possible Software Eng."_   
Whether the contract was for software engineering (a high failure-rate category in the past).  "This is not super robust, I kind of ran out of time to work on it" -Greg

### UCA   
__categorical__   
_levels: "Not UCA" ; "UCA"_   
Whether a contract is an "Undefinitized Contract Action" - where performance starts before the contract is finalized.  See http://www.acq.osd.mil/dpap/dars/dfars/html/archive_20010911/217_74.htm


### CRai   
__categorical__   
_levels: "[-0.001, 0.001)" ; "[ 0.150,   Inf]" ; "[ 0.001, 0.150)" ; "[  -Inf,-0.001)"_   
Ceiling-Raising change orders; how much the ceiling was raised, segmented into categories.

### NChg   
__categorical__   
_levels: "0" ; "1" ; "2" ; "[   3,3318]"_   
Number of change orders.

### Veh   
__categorical__   
_levels: "SINGLE AWARD" ; "Def/Pur" ; "Other IDV" ; "MULTIPLE AWARD"_   
Contract vehicle.  This reflects the number of bidders per task order.  "SINGLE AWARD" means task orders with only one authorized bidder, "MULTIPLE AWARD" means multiple authorized bidders on task orders, "Other IDV" is some other structure for task orders, "Def/Pur" is defind purpose (i.e. not a task order).  Greg says the anecdotal history is that Single Award IDVs got expensively out of hand in the past; Halliburton had a lot of them during Iraq.

### UnmodifiedNumberOfOffersReceived   
__numeric__   
The number of offers received on the initial task order (vs. a later modification?)  This wasn't totally clear to me; it may just be the unsegmented version of __Offr__   

### Term   
__categorical__   
_levels: "Unterminated" ; "Terminated"_   
Whether the contract was terminated.   

### UnmodifiedContractBaseAndAllOptionsValue   
__numeric__   
The original maximum ceiling of the contract.   

### SumOfisChangeOrder   
__numeric__   
A count of the number of change orders applied to the contract.   

### pChangeOrderUnmodifiedBaseAndAll   
__numeric__   
The percentage by which the contract breached the initial ceiling, for ceiling breaches caused by change orders.

### pChangeOrderObligated   
__numeric__   
The percentage by which the contract breached the eventual value, for ceiling breaches caused by change orders.

### pNewWorkUnmodifiedBaseAndAll   
__numeric__   
The percentage by which the contract breached the initial ceiling, for ceiling breaches caused by additions of new work.

### pNewWorkObligated   
__numeric__   
The percentage by which the contract breached the eventual value, for ceiling breaches caused by additions of new work.

### MinOfEffectiveDate   
__date__   
The first effective date of the contract.  (Start date?)   

### UnmodifiedCurrentCompletionDate   
__date__   
The projected completion date, at the time the contract was awarded.   

### LastCurrentCompletionDate   
__date__
The projected completion date, at the most recent modification of the contract.   

### IsClosed   
__categorical__   
_levels: "Unspecified" ; "Closed"_   
Whether the contract has a listed closeout ("Closed"), or whether Greg inferred it is closed ("Unspecified") based on the rule: Past ultimate completion date, or one year past current completion date with no further actions.  

### Action.Obligation   
__numeric__   
The amount obligated by the contract award or task order. 