SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO








































































/*---------------------TRANSACTIONAL SUMMARY----------------------
Summarised one line per order data layer - Reporting from tbl_Transaction_History table

Data structure and code implementation by Simon Robinson October 2006

REVISION HISTORY:
============
* November 2006 - Process changed to incorporate Dealer Fixes and Agent Updates - SR
* Fix applied to prevent silly values in the handset contribution field (ie worksheet no typed in) - SR
* RH (05/02/07 removed where ctr_type = 'ctr' due to HK issues
* RH (12/02/07 update CTR flag to CTR where missing (based on internal ctr PPlan hkeeping)
*RH (08/03/07 Insert CTR_Value into Exception_Flag_z, indicated CTN change within 14 days
*RH (12/09/07 Added 11 new fields to support CTR2
*RH Added CTR2 Process to run b4 Copy Over to MI01 
*(proc was formerly run as part of spPostTransaction_processing
* SR (04/12/2007 - Process and structure changed to include MusicStation and Network )
* SR (04/12/2007 - Leakage elements removed due to compliance reporting)
* DH (01/04/2008 - Altered code that looks at tbl_SOC_Commercial_Costs to add in Eff_Date and Exp_Date) ref: DH7
* DH (09/06/2008 - Added SUI Completed Deals reporting to end of SP)
* SR (30/07/2008 - Added Exception Table to assist SCR and One Liner process)

RELEASE NOTES:
==========
*                                                            
*
*

------------------------------------------------------------------------------------------*/

ALTER                                                                                                                      PROCEDURE SP_Txn_Summary AS
CREATE TABLE #Order_Summary (
--The order number, grouping together all elements of the sale
Order_Ref [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
CTN [varchar] (50) COLLATE Latin1_General_CI_AS NULL,
BAN [varchar] (50) COLLATE Latin1_General_CI_AS NULL,
--The date information, including the week and month of the year
Order_date  [datetime] NULL,
Order_Week [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
Order_Month [varchar] (50) COLLATE Latin1_General_CI_AS NULL,
--GROUPINGS - To enable dropdown filters on the report
Order_Hierachy  [varchar] (50) COLLATE Latin1_General_CI_AS NULL,
Order_Type [varchar] (50) COLLATE Latin1_General_CI_AS NULL,
Transaction_Type [varchar] (50) COLLATE Latin1_General_CI_AS NULL,
CTR_Type [varchar] (50) COLLATE Latin1_General_CI_AS NULL,
Migration_Type [varchar] (100) COLLATE Latin1_General_CI_AS NULL,
Subscriber_Status  [varchar] (50) COLLATE Latin1_General_CI_AS NULL,
Network  [varchar] (50) COLLATE Latin1_General_CI_AS NULL,
Primary_SOC   [varchar] (50) COLLATE Latin1_General_CI_AS NULL,
Primary_Price_Plan  [varchar] (50) COLLATE Latin1_General_CI_AS NULL,
Primary_Inc_Minutes   [varchar] (50) COLLATE Latin1_General_CI_AS NULL,
Primary_Handset  [varchar] (50) COLLATE Latin1_General_CI_AS NULL,
--AGENT groupings
Agent_ID [varchar] (50) COLLATE Latin1_General_CI_AS NULL,
Agent [varchar] (100) COLLATE Latin1_General_CI_AS NULL,
Team [varchar] (100) COLLATE Latin1_General_CI_AS NULL,
CCManager [varchar] (100) COLLATE Latin1_General_CI_AS NULL,
Site [varchar] (100) COLLATE Latin1_General_CI_AS NULL, 
Department [varchar] (100) COLLATE Latin1_General_CI_AS NULL, 
Reporting_Function [varchar] (100) COLLATE Latin1_General_CI_AS NULL,
Channel [varchar] (100) COLLATE Latin1_General_CI_AS NULL ,
Customer_Segment [varchar] (100) COLLATE Latin1_General_CI_AS NULL,
Business_Unit [varchar] (100) COLLATE Latin1_General_CI_AS NULL,

--Add fields to be added by cross referencing

Unique_Transactions INT NULL,

Contract_GROSS_Volume INT NULL,
Contract_NET_Volume INT NULL,
Contract_GROSS_Period_Total INT NULL,
Contract_NET_Period_Total INT NULL,
Contract_NET_Extended_Length INT NULL,
Contract_Returns INT NULL,
Contract_ShortTerm INT NULL,
Contract_SIMOnly INT NULL,

Handset_Volume INT NULL,
Handset_with_Contract INT NULL,
Handset_3G_Volume INT NULL,
Handset_Exchanges INT NULL,
Handset_Returns INT NULL,
Handset_Cost MONEY NULL,
Handset_Subsidy MONEY NULL,
Handset_Revenue MONEY NULL,

SIM_Card_Volume INT NULL,
SIM_Card_Cost MONEY NULL,
SIM_Card_Revenue MONEY NULL,

PAYT_SIM_Card_Volume INT NULL,
PAYT_SIM_Card_Cost MONEY NULL,
PAYT_SIM_Card_Revenue MONEY NULL,

Delivery_Charge_Volume INT NULL,
Delivery_Charge_Cost MONEY NULL,
Delivery_Charge_Revenue MONEY NULL,

Accessory_Volume INT NULL,
Accessory_Cost MONEY NULL,
Accessory_Revenue MONEY NULL,

Other_Hardware_Volume INT NULL,
Other_Hardware_Cost MONEY NULL,
Other_Hardware_Revenue MONEY NULL,

Price_Plan_Volume INT NULL,
Price_Plan_CTR_Volume INT NULL,
Price_Plan_STCT_Volume INT NULL,
Price_Plan_Volume_with_Contract INT NULL,
Price_Plan_Volume_NoContract INT NULL,
Price_Plan_Volume_Contract_CTR INT NULL,
Price_Plan_Volume_NoContract_CTR INT NULL,
Price_Plan_Short_Term_Cost MONEY NULL,
Price_Plan_Lifetime_Cost MONEY NULL,
Price_Plan_Revenue MONEY NULL,

Price_Plan_Commercial_ST_Cost MONEY NULL,
Price_Plan_Commercial_LT_Cost MONEY NULL,

Extras_Volume INT NULL,
Extras_Volume_CTR INT NULL,
Extras_FLR_Volume INT NULL,
Extras_FLR_CTR INT NULL,
Extras_Text_Bundle INT NULL,
Extras_Text_Bundle_CTR INT NULL,
Extras_Minutes_Bundle INT NULL,
Extras_Minutes_Bundle_CTR INT NULL,
Extras_Content INT NULL,
Extras_Content_CTR INT NULL,
Extras_STC_Volume INT NULL,
Extras_STC_CTR INT NULL,
Extras_STC_Paid INT NULL,
Extras_VP_Volume  INT NULL,
Extras_Insurance_Volume INT NULL,
Extras_Family_Volume INT NULL,
Extras_Family_CTR_Volume Int null,
Extras_MobileInternet_Volume INT NULL,
Extras_MusicStation_Volume INT NULL,
Extras_Other INT NULL,
Extras_Short_Term_Cost MONEY NULL,
Extras_Lifetime_Cost MONEY NULL,
Extras_Revenue MONEY NULL,

Extras_Commercial_ST_Cost MONEY NULL,
Extras_Commercial_LT_Cost MONEY NULL,

Discounts_Volume INT NULL,
Discounts_Recurring_Volume INT NULL, 
Discounts_Usage_Volume INT NULL,
Discounts_No_End_Date_Volume INT NULL,
Discounts_Cost MONEY NULL,

Credits_Volume INT NULL,
Credits_Adjustment_Volume INT NULL,
Credits_Goodwill_Volume INT NULL,
Credits_Cashback_Volume INT NULL,
Credits_Cost_Total MONEY NULL,
Credits_Adjustment_Cost MONEY NULL,
Credits_Goodwill_Cost MONEY NULL,
Credits_Cashback_Cost MONEY NULL,

SUI_Contracts INT NULL,
SUI_Defaults INT NULL,
SUI_RIV MONEY NULL,
SUI_Band VARCHAR(10) COLLATE Latin1_General_CI_AS NULL ,

CTR_Bonus_Available INT NULL,
CTR_Bonus_Used INT NULL,


Exception_A_Flag INT NULL,
Exception_B_Flag INT NULL,
Exception_C_Flag INT NULL,
Exception_D_Flag INT NULL,
Exception_E_Flag INT NULL,
Exception_F_Flag INT NULL,
Exception_G_Flag INT NULL,
Exception_H_Flag INT NULL,
Exception_I_Flag INT NULL,
Exception_J_Flag INT NULL,
Exception_K_Flag INT NULL,
Exception_L_Flag INT NULL,
Exception_M_Flag INT NULL,
Exception_N_Flag INT NULL,
Exception_O_Flag INT NULL,
Exception_P_Flag INT NULL,
Exception_Q_Flag INT NULL,
Exception_R_Flag INT NULL,
Exception_S_Flag INT NULL,
Exception_T_Flag INT NULL,
Exception_U_Flag INT NULL,
Exception_V_Flag INT NULL,
Exception_W_Flag INT NULL,
Exception_X_Flag INT NULL,
Exception_Y_Flag INT NULL,
Exception_Z_Flag INT NULL,
CTR_Text_Soc [varchar] (50) COLLATE Latin1_General_CI_AS NULL,
CTR_10PC_Flag INT NULL,
CTR_3MHP_Flag INT NULL,
CTR_6MHP_Flag Int null,
CTR_Matrix_Type [varchar] (10) COLLATE Latin1_General_CI_AS NULL,
CTR_Deal_Type [varchar] (10) COLLATE Latin1_General_CI_AS NULL,
CTR_Plan_Type [varchar] (20) COLLATE Latin1_General_CI_AS NULL,
CTR_Lookup [varchar] (20) COLLATE Latin1_General_CI_AS NULL,
CTR_Contract_Len INT NULL,
CTR_Elig_Txt INT NULL,


--New CTR2 Fields (added RH 12/09/2007
[CTR_PricePoint] money null,
[CTR_Unlim_LL_Extras] int null,
[CTR_Unlim_SMS_Extras] int null,
[CTR_FWC_Extras] int null,
[CTR_Plan_SMS] varchar(10) null,
[CTR_SIMONLY_Flag] int null,
[CTR_MealDeal_Flag] int null,
[CTR_Incl_MINS] int null,
[CTR_Extras_In_Plan] int null,
[CTR_Elig_SMS] varchar(10) null,
[CTR_Addnl_SMS] varchar(10) null,
[CTR_VMI_Flag] int null,
[CTR_ICS_Flag] int null
 )


INSERT INTO #Order_Summary (
--Order Summary Data
Order_Ref, CTN, BAN, Order_Date, Order_Week, Order_Month, Order_Type,  Subscriber_Status, Network,
Agent_ID, Agent, Team, CCManager, Site, Department, Reporting_Function, Channel, Customer_Segment, Business_Unit, 
--Contract and Transaction Counts
Unique_Transactions,Contract_GROSS_Volume, Contract_NET_Volume, Contract_GROSS_Period_Total, Contract_NET_Period_Total, Contract_NET_Extended_Length, 
Contract_ShortTerm, Contract_SIMOnly,
--Handset Volumes and Costs
Handset_Volume,Handset_3G_Volume, Handset_Exchanges, Handset_Cost, Handset_Subsidy, Handset_Revenue,
--Accessory Volumes
SIM_Card_Volume,SIM_Card_Cost,SIM_Card_Revenue,PAYT_SIM_Card_Volume,PAYT_SIM_Card_Cost,PAYT_SIM_Card_Revenue,
Delivery_Charge_Volume,Delivery_Charge_Cost,Delivery_Charge_Revenue,Accessory_Volume,Accessory_Cost,Accessory_Revenue,
Other_Hardware_Volume,Other_Hardware_Cost,Other_Hardware_Revenue,
--Price Plan
Price_Plan_Volume,Price_Plan_CTR_Volume,Price_Plan_STCT_Volume, Price_Plan_Short_Term_Cost,Price_Plan_Lifetime_Cost,
Price_Plan_Revenue,
--Extras
Extras_Volume,Extras_Volume_CTR,Extras_FLR_Volume,Extras_FLR_CTR,Extras_Text_Bundle,Extras_Text_Bundle_CTR,Extras_Minutes_Bundle,
Extras_Minutes_Bundle_CTR,Extras_Content,Extras_Content_CTR,Extras_STC_Volume,Extras_STC_CTR,Extras_STC_Paid,Extras_VP_Volume,
Extras_Insurance_Volume,Extras_Family_Volume,Extras_MobileInternet_Volume, Extras_MusicStation_Volume, Extras_Other,Extras_Short_Term_Cost,Extras_Lifetime_Cost,Extras_Revenue,
--Discounts and Credits
Discounts_Volume,Discounts_Recurring_Volume, Discounts_Usage_Volume,Discounts_No_End_Date_Volume, Discounts_Cost,
Credits_Volume,Credits_Adjustment_Volume,Credits_Goodwill_Volume,Credits_Cashback_Volume,Credits_Cost_Total, Credits_Adjustment_Cost,
Credits_Goodwill_Cost,Credits_Cashback_Cost,
--SUI/TPC
SUI_Contracts,SUI_RIV,SUI_Band,
--Customer Management Data

Exception_Z_Flag,
CTR_PricePoint,
CTR_Unlim_LL_Extras,
CTR_Unlim_SMS_Extras,
CTR_FWC_Extras,
CTR_Plan_SMS,
CTR_SIMONLY_Flag,
CTR_MealDeal_Flag,
CTR_Incl_MINS,
CTR_Extras_In_Plan,
CTR_Elig_SMS,
CTR_Addnl_SMS,
CTR_VMI_Flag,
CTR_ICS_Flag
 )

SELECT Order_Ref, CTN, BAN, Order_Date, WeekText, MonthText, Dl_ActivityType, 
CASE 	WHEN Dl_Subscription_Status = 'A' THEN 'Active'
	WHEN Dl_Subscription_Status = 'R' THEN 'Reserved'
	WHEN Dl_Subscription_Status = 'S' THEN 'Suspended'
	WHEN Dl_Subscription_Status = 'C' THEN 'Cancelled'
	ELSE 'Unknown' END, Dl_Network,
Dl_Agent_ID, Dl_Agent, Dl_Team, Dl_CCM, Dl_Site, Dl_Department, Dl_Function, Dl_Channel, IsNull(Dl_AccountType,'Consumer'), Dl_BusinessUnit, 1,

--Contracts
SUM(CASE
	WHEN Txn_ProductType LIKE 'Contract%' AND Txn_Gross_Period > 11 THEN 1 ELSE 0 END),
SUM(CASE
	WHEN Txn_ProductType = 'Contract' AND Txn_Net_Period > 11 THEN 1 ELSE 0 END),
SUM(CASE
	WHEN Txn_ProductType = 'Contract' THEN Txn_Gross_Period ELSE 0 END),
SUM(CASE
	WHEN Txn_ProductType = 'Contract' THEN Txn_Net_Period ELSE 0 END),
SUM(CASE
	WHEN Txn_ProductType = 'Contract' AND Txn_Net_Period > 17 THEN 1 ELSE 0 END),
SUM(CASE
	WHEN Txn_ProductType = 'Contract' AND Txn_Net_Period < 12 THEN 1 ELSE 0 END),
0,
--SUM(CASE
	--WHEN Txn_ProductType = 'Price Plan' AND Txn_ProductCode IN (SELECT [VF Code] FROM mireferencetables.dbo.simonlysocs where Contract = 1) THEN 1 ELSE 0 END),
--AMENDMENT MADE BY SR - TXN QUANTITY 25/11/08
--Handsets
SUM(CASE
	WHEN Txn_ProductType = 'Handset' THEN Txn_Quantity ELSE 0 END),
SUM(CASE
	WHEN Txn_ProductType = 'Handset' AND Txn_Flag_B = '3G' THEN 1 ELSE 0 END),
SUM(CASE
	WHEN Txn_ProductType = 'Handset' AND Txn_Flag_E = 'Exchange' THEN 1 ELSE 0 END),
SUM(CASE
	WHEN Txn_ProductType = 'Handset'  THEN Txn_OneOff_Cost ELSE 0 END),
--Handet Subsidy (SR 17/11/2008)
0,
SUM(CASE
	WHEN Txn_ProductType = 'Handset' AND Txn_OneOff_Revenue < 1000 THEN Txn_OneOff_Revenue ELSE 0 END),
--Accessories
--SIMS
SUM(CASE
	WHEN Txn_ProductCode IN ('00SIM1','000UCP','005654','005660') THEN Txn_Quantity ELSE 0 END),
SUM(CASE
	WHEN Txn_ProductCode IN ('00SIM1','000UCP','005654','005660') THEN Txn_OneOff_Cost ELSE 0 END),
SUM(CASE
	WHEN Txn_ProductCode IN ('00SIM1','000UCP','005654','005660') AND Txn_OneOff_Revenue < 500 THEN Txn_OneOff_Revenue ELSE 0 END),
SUM(CASE
	WHEN Txn_ProductCode IN ('PAYTSU','PTSIM2','00GID1','058807','000021','008201') THEN Txn_Quantity ELSE 0 END),
SUM(CASE
	WHEN Txn_ProductCode IN ('PAYTSU','PTSIM2','00GID1','058807','000021','008201')  THEN Txn_OneOff_Cost ELSE 0 END),
SUM(CASE
	WHEN Txn_ProductCode IN ('PAYTSU','PTSIM2','00GID1','058807','000021','008201') AND Txn_OneOff_Revenue < 500 THEN Txn_OneOff_Revenue ELSE 0 END),
SUM(CASE
	WHEN Txn_ProductType = 'Delivery Charges' THEN 1 ELSE 0 END),
SUM(CASE
	WHEN Txn_ProductType = 'Delivery Charges' THEN Txn_OneOff_Cost ELSE 0 END),
SUM(CASE
	WHEN Txn_ProductType = 'Delivery Charges' AND Txn_OneOff_Revenue < 500 THEN Txn_OneOff_Revenue ELSE 0 END),
SUM(CASE
	WHEN Txn_ProductType LIKE 'Accessory%'  AND Txn_ProductCode NOT IN ('00SIM1','000UCP','005654','005660','PAYTSU','PTSIM2','00GID1','058807','000021','008201','TMTIVC') THEN Txn_Quantity ELSE 0 END),
SUM(CASE
	WHEN Txn_ProductType LIKE 'Accessory%' AND Txn_ProductCode NOT IN ('00SIM1','000UCP','005654','005660','PAYTSU','PTSIM2','00GID1','058807','000021','008201','TMTIVC') THEN Txn_OneOff_Cost ELSE 0 END),
SUM(CASE
	WHEN Txn_ProductType LIKE 'Accessory%' AND Txn_ProductCode NOT IN ('00SIM1','000UCP','005654','005660','PAYTSU','PTSIM2','00GID1','058807','000021','008201','TMTIVC') AND Txn_OneOff_Revenue < 500 THEN Txn_OneOff_Revenue ELSE 0 END),
SUM(CASE
	WHEN Txn_ProductCode = 'TMTIVC' THEN Txn_Quantity ELSE 0 END),
SUM(CASE
	WHEN Txn_ProductCode = 'TMTIVC' THEN Txn_OneOff_Cost ELSE 0 END),
SUM(CASE
	WHEN  Txn_ProductCode = 'TMTIVC' AND Txn_OneOff_Revenue < 500 THEN Txn_OneOff_Revenue ELSE 0 END),
--PRICE PLANS
SUM(CASE
	WHEN Txn_ProductType = 'Price Plan' AND Txn_ProductCode NOT IN ('MVSZ130S','MVSZ133J','MVSZ197A','MVSZ306D','VSZ130LK3') THEN 1 ELSE 0 END),
SUM(CASE
	WHEN Txn_ProductType = 'Price Plan' AND Txn_Flag_A = 'CTR' THEN 1 ELSE 0 END),
SUM(CASE
	WHEN Txn_ProductType = 'Price Plan' AND Dl_Flag_B LIKE '(STCT)%' THEN 1 ELSE 0 END),
SUM(CASE
	WHEN Txn_ProductType = 'Price Plan' THEN Txn_OneOff_Cost  ELSE 0 END),
SUM(CASE
	WHEN Txn_ProductType = 'Price Plan' THEN Txn_Recurring_Cost  ELSE 0 END),
SUM(CASE
	WHEN Txn_ProductType = 'Price Plan' THEN Txn_Recurring_Revenue  ELSE 0 END),
--EXTRAS
SUM(CASE
	WHEN Txn_ProductType = 'Extras' AND Txn_ProductDescription NOT LIKE '%Free%' THEN 1 ELSE 0 END),
SUM(CASE
	WHEN Txn_ProductType = 'Extras' AND Txn_ProductDescription NOT LIKE '%Free%' AND Txn_Flag_A = 'CTR' THEN 1 ELSE 0 END),
SUM(CASE 
	WHEN Txn_ProductType = 'Price Plan' AND Txn_Flag_D = 'FLR' THEN 1 ELSE 0 END),
SUM(CASE 
	WHEN Txn_ProductType = 'Price Plan' AND Txn_Flag_D = 'FLR' AND Txn_Flag_A = 'CTR' THEN 1 ELSE 0 END),
SUM(CASE
	WHEN Txn_ProductType = 'Extras' AND Txn_Flag_B = 'Text Bundle' THEN 1 ELSE 0 END),
SUM(CASE
	WHEN Txn_ProductType = 'Extras' AND Txn_Flag_B = 'Text Bundle' AND Txn_Flag_A = 'CTR' THEN 1 ELSE 0 END),
SUM(CASE 
	WHEN Txn_ProductType = 'Price Plan' AND Txn_Flag_E = 'Double Minutes' THEN 1 ELSE 0 END),
SUM(CASE 
	WHEN Txn_ProductType = 'Price Plan' AND Txn_Flag_E = 'Double Minutes' AND Txn_Flag_A = 'CTR'  THEN 1 ELSE 0 END),
SUM(CASE
	WHEN Txn_ProductType = 'Extras' AND Txn_Flag_B = 'Mobile_TV' THEN 1 ELSE 0 END),
SUM(CASE
	WHEN Txn_ProductType = 'Extras' AND Txn_Flag_B = 'Mobile_TV' AND Txn_Flag_A = 'CTR' THEN 1 ELSE 0 END),
SUM(CASE 
	WHEN Txn_ProductType = 'Price Plan' AND Txn_Flag_B = 'STC' THEN 1 ELSE 0 END),
SUM(CASE 
	WHEN Txn_ProductType = 'Price Plan' AND Txn_Flag_B = 'STC' AND Txn_Flag_A = 'CTR'  THEN 1 ELSE 0 END),
SUM(CASE 
	WHEN Txn_ProductType = 'Extras' AND Txn_ProductDescription LIKE '%Stop The Clock%'  THEN 1 ELSE 0 END),
SUM(CASE
	WHEN Txn_ProductType = 'Price Plan' AND Txn_Flag_C = 'VP' THEN 1 ELSE 0 END),
SUM(CASE
	WHEN Txn_ProductType = 'Extras' AND Txn_Flag_B = 'Insurance' AND Txn_ProductDescription NOT LIKE '%Free%' THEN 1 ELSE 0 END),
SUM(CASE
	WHEN Txn_ProductType = 'Extras' AND Txn_Flag_B = 'Family'  THEN 1 ELSE 0 END),
SUM(CASE
	WHEN Txn_ProductType = 'Extras' AND Txn_ProductCode LIKE 'MOBINT%'  THEN 1 
	WHEN Txn_ProductType = 'Price Plan' AND Txn_ProductCode LIKE 'VMI%' THEN 1 
	WHEN Txn_ProductType = 'Extras' AND Txn_ProductCode LIKE 'ATVMI%' THEN 1 
	WHEN Txn_ProductType = 'Extras' AND Txn_ProductCode IN ('ATBISWB','ATBISWB1','ATVBEWB') THEN 1 ELSE 0 END),
SUM(CASE
	WHEN Txn_ProductType = 'Extras' AND Txn_ProductCode IN ('MOZART003','MOZART004','MOZART007') THEN 1
	WHEN Txn_ProductType = 'Price Plan' AND Txn_ProductDescription LIKE '%MusicStation%' THEN 1
	ELSE 0 END),
SUM(CASE
	WHEN Txn_PRoductType = 'Extras' AND Txn_Flag_B = 'Other' THEN 1 ELSE 0 END),
SUM(CASE
	WHEN Txn_ProductType = 'Extras'  THEN Txn_OneOff_Cost ELSE 0 END),
SUM(CASE
	WHEN Txn_ProductType = 'Extras'  THEN (Txn_Recurring_Cost) ELSE 0 END),
SUM(CASE
	WHEN Txn_ProductType = 'Extras'  THEN Txn_Recurring_Revenue ELSE 0 END),
--DISCOUNTS
SUM(CASE
	WHEN Txn_ProductType LIKE '%Discount%' THEN 1 ELSE 0 END),
SUM(CASE
	WHEN Txn_ProductType = 'Recurring Discount' THEN 1 ELSE 0 END),
SUM(CASE
	WHEN Txn_ProductType = 'Useage Discount' THEN 1 ELSE 0 END),
SUM(CASE
	WHEN Txn_ProductType LIKE '%Discount%' AND Txn_End_Date IS NULL THEN 1 ELSE 0 END),
SUM(CASE
	WHEN Txn_ProductType LIKE '%Discount%' THEN (Txn_Recurring_Cost * Txn_Gross_Period) ELSE 0 END),
SUM(CASE
	WHEN Txn_ProductType LIKE 'Credit Note' THEN 1 ELSE 0 END),
SUM(CASE
	WHEN Txn_ProductType LIKE 'Credit Note' AND Txn_Flag_A = 'Adjustment' THEN 1 ELSE 0 END),
SUM(CASE
	WHEN Txn_ProductType LIKE 'Credit Note' AND Txn_Flag_A = 'Goodwill' THEN 1 ELSE 0 END),
SUM(CASE
	WHEN Txn_ProductType LIKE 'Credit Note' AND Txn_Flag_A = 'Cashback' THEN 1 ELSE 0 END),
SUM(CASE
	WHEN Txn_ProductType LIKE 'Credit Note' THEN Txn_OneOff_Cost ELSE 0 END),
SUM(CASE
	WHEN Txn_ProductType LIKE 'Credit Note' AND Txn_Flag_A = 'Adjustment' THEN Txn_OneOff_Cost ELSE 0 END),
SUM(CASE
	WHEN Txn_ProductType LIKE 'Credit Note' AND Txn_Flag_A = 'Goodwill' THEN Txn_OneOff_Cost ELSE 0 END),
SUM(CASE
	WHEN Txn_ProductType LIKE 'Credit Note' AND Txn_Flag_A = 'Cashback' THEN Txn_OneOff_Cost ELSE 0 END),

--TPC and SUI Flags
SUM(CASE
	WHEN Txn_ProductType LIKE '%Contract%' AND Txn_Flag_A = 'SUI/RSC' THEN 1 ELSE 0 END),
SUM(CASE
	WHEN Txn_ProductType LIKE '%Contract%' AND Txn_Gross_Period > 11 AND Txn_Flag_A = 'SUI/RSC' THEN Cast(Txn_Flag_C AS MONEY) 
	WHEN Txn_ProductType LIKE '%Contract%' AND Txn_Gross_Period > 11 AND Txn_Flag_A IS NULL AND Dl_Department = 'Inbound Retention' AND Dl_ActivityType = 'Retention' AND Dl_Site = 'Stoke' THEN 174.20
	WHEN Txn_ProductType LIKE '%Contract%' AND Txn_Gross_Period > 11 AND Txn_Flag_A IS NULL AND Dl_Department = 'Inbound Retention' AND Dl_ActivityType = 'Retention' AND Dl_Site = 'Garlands' THEN 174.20
	WHEN Txn_ProductType LIKE '%Contract%' AND Txn_Gross_Period > 11  AND Txn_Flag_A IS NULL AND Dl_Department = 'Customer Saves' AND  Dl_ActivityType = 'Retention' AND Dl_Site = 'Stoke' THEN 284.06
	WHEN Txn_ProductType LIKE '%Contract%' AND Txn_Gross_Period > 11  AND Txn_Flag_A IS NULL AND Dl_Department = 'Customer Saves' AND  Dl_ActivityType = 'Retention' AND Dl_Site = 'Warrington' THEN 284.06
	WHEN Txn_ProductType LIKE '%Contract%' AND Txn_Gross_Period > 11 AND Txn_Flag_A IS NULL AND Dl_Department = 'High Value Retention' AND Dl_ActivityType = 'Retention'AND Dl_Site = 'Stoke' THEN 304.17
	WHEN Txn_ProductType LIKE '%Contract%' AND Txn_Gross_Period > 11 AND Txn_Flag_A IS NULL AND Dl_Department = 'Outbound Retention' AND Dl_ActivityType = 'Retention' AND Dl_Site = 'Stoke' THEN 351.26
	WHEN Txn_ProductType LIKE '%Contract%' AND Txn_Gross_Period > 11 AND Txn_Flag_A IS NULL AND Dl_Department = 'Garlands Pro Ret' AND Dl_ActivityType = 'Retention' AND Dl_Site = 'Garlands' THEN 220.00
	WHEN Txn_ProductType LIKE '%Contract%' AND Txn_Gross_Period > 11 AND Txn_Flag_A IS NULL AND Dl_Department = 'Garlands Pro Ret Multi' AND Dl_ActivityType = 'Retention' AND Dl_Site = 'Garlands' THEN 300.00
	WHEN Txn_ProductType LIKE '%Contract%' AND Txn_Gross_Period > 11 AND Txn_Flag_A IS NULL AND Dl_Department = 'Ultra High Value' AND Dl_ActivityType = 'Retention' AND Dl_Site = 'Stoke' THEN 370.00
	WHEN Txn_ProductType LIKE '%Contract%' AND Txn_Gross_Period > 11 AND Txn_Flag_A IS NULL AND Dl_Department = 'LBM EBU Pro Ret' AND Dl_ActivityType = 'Retention' AND Dl_Site = 'LBM Middleton' THEN 220.00
	WHEN Txn_ProductType LIKE '%Contract%' AND Txn_Gross_Period > 11 AND Txn_Flag_A IS NULL AND Dl_Department = 'Customer Retention' AND Dl_ActivityType = 'Retention' AND Dl_Site = 'Stoke' THEN 220.00
	WHEN Txn_ProductType LIKE '%Contract%' AND Txn_Gross_Period > 11 AND Txn_Flag_A IS NULL AND Dl_Department = 'Customer Retention' AND Dl_ActivityType = 'Retention' AND Dl_Site = 'Garlands' THEN 220.00
	ELSE 0 END),
Max(CASE
	WHEN Txn_ProductType LIKE '%Contract%' AND Txn_Flag_A = 'SUI/RSC' AND Txn_Flag_D NOT IN ('COM','WERT') THEN Txn_Flag_B ELSE '0' END),

CRT_Value,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0


FROM tbl_Transaction_Current A LEFT OUTER JOIN mireferencetables.dbo.tbl_ref_dates B
ON A.Order_Date = B.NewDate 
GROUP BY Order_Ref, CTN, BAN, Order_Date, WeekText, MonthText, Dl_ActivityType, 
CASE 	WHEN Dl_Subscription_Status = 'A' THEN 'Active'
	WHEN Dl_Subscription_Status = 'R' THEN 'Reserved'
	WHEN Dl_Subscription_Status = 'S' THEN 'Suspended'
	WHEN Dl_Subscription_Status = 'C' THEN 'Cancelled'
	ELSE 'Unknown' END, Dl_Network,
Dl_Agent_ID, Dl_Agent, Dl_Team, Dl_CCM, Dl_Site, Dl_Department, Dl_Function, Dl_Channel, Dl_AccountType, Dl_BusinessUnit, crt_value



UPDATE #Order_Summary
SET Contract_SIMOnly = 1
FROM #Order_Summary A JOIN tbl_Transaction_Current B
ON A.Order_Ref = B.Order_Ref
AND A.CTN = B.CTN
WHERE B.Txn_ProductCode IN (SELECT [VF Code] FROM mireferencetables.dbo.simonlysocs)
AND Contract_Net_Volume < 1

UPDATE #Order_Summary
SET SUI_Defaults = 1
WHERE SUI_Contracts = 0 AND SUI_RIV > 0

UPDATE #Order_Summary
SET SUI_Defaults = 1
WHERE SUI_Contracts = 0 AND Department IN ('Customer Saves','Outbound Retention','Inbound Retention','High Value Retention','Ultra High Value','Customer Retention')
AND Contract_Gross_Volume > 0

UPDATE #Order_Summary
SET SUI_Defaults = 1
WHERE SUI_Contracts = 1 AND SUI_RIV = 0

UPDATE #Order_Summary
SET SUI_RIV = B.DefaultRIV
FROM #Order_Summary A JOIN tbl_RIVDefault B
ON A.Department = B.Department
WHERE A.SUI_Contracts = 1 AND A.SUI_RIV = 0

UPDATE #Order_Summary
SET SUI_Contracts = 0
WHERE SUI_Contracts = 1 AND SUI_Defaults = 1



CREATE TABLE #TempContracts (
Order_Ref [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
CTN [varchar] (50) COLLATE Latin1_General_CI_AS NULL,
Contract INT NULL,
Handset INT NULL,
Price_Plan INT NULL,
CTR INT NULL,
SUI INT NULL)

INSERT INTO #TempContracts (Order_Ref, CTN, Contract)
SELECT Order_Ref, CTN, 1 FROM tbl_Transaction_Current
WHERE Txn_ProductType = 'Contract'
GROUP BY Order_Ref, CTN

UPDATE #TempContracts
SET Handset = 1
FROM #TempContracts A JOIN tbl_Transaction_Current B
ON A.Order_Ref = B.Order_Ref and A.CTN = B.CTN
WHERE B.txn_ProductType = 'Handset'

UPDATE #TempContracts
SET Price_Plan = 1
FROM #TempContracts A JOIN tbl_Transaction_Current B
ON A.Order_Ref = B.Order_Ref and A.CTN = B.CTN
WHERE B.txn_ProductType = 'Price Plan'

UPDATE #TempContracts
SET CTR = 1
FROM #TempContracts A JOIN tbl_Transaction_Current B
ON A.Order_Ref = B.Order_Ref and A.CTN = B.CTN
WHERE B.txn_ProductType = 'Price Plan' AND Txn_Flag_A = 'CTR'

UPDATE #TempContracts
SET SUI = 1
FROM #TempContracts A JOIN tbl_Transaction_Current B
ON A.Order_Ref = B.Order_Ref and A.CTN = B.CTN
WHERE B.txn_ProductType = 'Contract' AND Txn_Flag_B = 'SUI'


UPDATE #Order_Summary
SET Transaction_Type = 'Contract'
FROM #Order_Summary A JOIN #TempContracts B
ON A.Order_Ref = B.Order_Ref and A.CTN = B.CTN

UPDATE #Order_Summary
SET Transaction_Type = 'Non Contract'
WHERE Transaction_Type IS NULL


UPDATE #Order_Summary
SET Order_Hierachy = 'Contract' WHERE Contract_Gross_Volume > 0

UPDATE #Order_Summary
SET Order_Hierachy = 'SIM Only' WHERE Contract_SIMONly > 0

UPDATE #Order_Summary
SET Order_Hierachy = 'Handset Exchange' WHERE Handset_Exchanges > 0

UPDATE #Order_Summary
SET Order_Hierachy = 'Maintenence' WHERE Order_Hierachy IS NULL

-- 



--===REMOVED SR 20/11/08
-- CREATE TABLE #Commercial_Costs_PP (
-- Order_Reference VARCHAR(50) NULL,
-- CTN VARCHAR(50) NULL,
-- ProductType VARCHAR(50),
-- Recurring_Cost MONEY NULL,
-- Fixed_Cost MONEY NULL)
-- 
-- INSERT INTO #Commercial_Costs_PP
-- SELECT A.Order_Ref, A.CTN, A.txn_ProductType, B.Recurring, B.Fixed
-- FROM tbl_Transaction_Current A LEFT OUTER JOIN mireferencetables.dbo.tbl_SOC_Commercial_Costs B
-- ON A.txn_ProductCode = B.SOC
-- WHERE A.txn_ProductType IN ('Price Plan')
-- AND A.Dl_Flag_B NOT LIKE '%STCT%'
-- --DH7
-- AND A.Order_Date Between b.Eff_Date and Exp_Date
-- 
-- SELECT * FROM #Commercial_Costs_PP
-- 
-- CREATE TABLE #Commercial_Costs_EX (
-- Order_Reference VARCHAR(50) NULL,
-- CTN VARCHAR(50) NULL,
-- ProductType VARCHAR(50),
-- Recurring_Cost MONEY NULL,
-- Fixed_Cost MONEY NULL)
-- 
-- INSERT INTO #Commercial_Costs_EX
-- SELECT A.Order_Ref, A.CTN, A.txn_ProductType, B.Recurring, B.Fixed
-- FROM tbl_Transaction_Current A LEFT OUTER JOIN mireferencetables.dbo.tbl_SOC_Commercial_Costs B
-- ON A.txn_ProductCode = B.SOC
-- WHERE A.txn_ProductType IN ('Extras')
-- AND A.Dl_Flag_B NOT LIKE  '%STCT%'
-- --DH7
-- AND A.Order_Date Between b.Eff_Date and Exp_Date
-- 
-- 
-- UPDATE #Order_Summary
-- SET Price_Plan_Commercial_ST_Cost = B.Fixed_Cost,
-- Price_Plan_Commercial_LT_Cost = B.Recurring_Cost
-- FROM #Order_Summary A JOIN #Commercial_Costs_PP B
-- ON A.Order_Ref = B.Order_Reference
-- AND A.CTN = B.CTN
-- AND B.ProductType = 'Price Plan'
-- 
-- UPDATE #Order_Summary
-- SET Extras_Commercial_ST_Cost = B.Fixed_Cost,
-- Extras_Commercial_LT_Cost = B.Recurring_Cost
-- FROM #Order_Summary A JOIN #Commercial_Costs_EX B
-- ON A.Order_Ref = B.Order_Reference
-- AND A.CTN = B.CTN
-- AND B.ProductType = 'Extras'


UPDATE #Order_Summary
SET Handset_with_Contract = B.Handset
FROM #Order_Summary A  JOIN #TempContracts B
ON A.Order_Ref = B.Order_Ref and A.CTN = B.CTN
WHERE B.Handset = 1

UPDATE #Order_Summary
SET Handset_With_Contract = 0
WHERE Handset_With_Contract IS NULL

UPDATE #Order_Summary
SET Price_Plan_Volume_with_Contract = B.Price_Plan
FROM #Order_Summary A  JOIN #TempContracts B
ON A.Order_Ref = B.Order_Ref and A.CTN = B.CTN
WHERE B.Price_Plan = 1

UPDATE #Order_Summary
SET Price_Plan_Volume_with_Contract = 0
WHERE Price_Plan_Volume_with_Contract IS NULL

UPDATE #Order_Summary
SET Price_Plan_Volume_NoContract = (Price_Plan_Volume - Price_Plan_Volume_with_Contract)

UPDATE #Order_Summary
SET Price_Plan_Volume_Contract_CTR = B.CTR
FROM #Order_Summary A  JOIN #TempContracts B
ON A.Order_Ref = B.Order_Ref and A.CTN = B.CTN
WHERE B.Price_Plan = 1 AND B.CTR = 1

UPDATE #Order_Summary
SET Price_Plan_Volume_Contract_CTR = 0
WHERE Price_Plan_Volume_Contract_CTR IS NULL

CREATE TABLE #TempCTR (
Order_Ref [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
CTN [varchar] (50) COLLATE Latin1_General_CI_AS NULL)

INSERT INTO #TempCTR
SELECT Order_Ref, CTN FROM tbl_Transaction_Current
WHERE Txn_ProductType = 'Price Plan' AND Txn_Flag_A = 'CTR'
GROUP BY Order_Ref, CTN

UPDATE #Order_Summary
SET CTR_Type = 'CTR'
FROM #Order_Summary A JOIN #TempCTR B
ON A.Order_Ref = B.Order_Ref and A.CTN = B.CTN

UPDATE #Order_Summary
SET CTR_Type = 'Non CTR'
WHERE CTR_Type IS NULL

UPDATE #Order_Summary
SET Price_Plan_Volume_NoContract_CTR = 1
WHERE CTR_Type = 'CTR' AND Price_Plan_Volume_NoContract = 1

UPDATE #Order_Summary
SET Price_Plan_Volume_NoContract_CTR = 0
WHERE Price_Plan_Volume_NoContract_CTR IS NULL

CREATE TABLE #PrimaryItems (
Order_Ref [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
CTN [varchar] (50) COLLATE Latin1_General_CI_AS NULL,
PricePlanDesc  [varchar] (50) COLLATE Latin1_General_CI_AS NULL,
PricePlanSOC   [varchar] (50) COLLATE Latin1_General_CI_AS NULL,
HandsetDesc  [varchar] (50) COLLATE Latin1_General_CI_AS NULL )

INSERT INTO #PrimaryItems (Order_Ref, CTN)
SELECT Order_Ref, CTN FROM tbl_Transaction_Current
GROUP BY Order_Ref, CTN

UPDATE #PrimaryItems
SET PricePlanDesc = B.Txn_ProductDescription,
PricePlanSOC = B.Txn_ProductCode
FROM #PrimaryItems A JOIN tbl_Transaction_Current B
ON A.Order_Ref = B.Order_Ref and A.CTN = B.CTN
WHERE B.Txn_ProductType = 'Price Plan' 

UPDATE #PrimaryItems
SET HandsetDesc = B.Txn_ProductDescription
FROM #PrimaryItems A JOIN tbl_Transaction_Current B
ON A.Order_Ref = B.Order_Ref and A.CTN = B.CTN
WHERE B.Txn_ProductType = 'Handset' 

UPDATE #PrimaryItems
SET PricePlanDesc = 'No Price Plan'
WHERE PricePlanDesc IS NULL

UPDATE #PrimaryItems
SET HandsetDesc = 'No Handset'
WHERE HandsetDesc IS NULL

UPDATE #Order_Summary
SET Primary_Price_Plan = B.PricePlanDesc,
Primary_SOC = B.PricePlanSOC,
Primary_Handset = B.HandsetDesc
FROM #Order_Summary A JOIN #PrimaryItems B
ON A.Order_Ref = B.Order_Ref and A.CTN = B.CTN

UPDATE #Order_Summary
SET Migration_Type = B.Dl_Flag_B
FROM #Order_Summary A JOIN tbl_Transaction_Current B
ON A.Order_Ref = B.Order_Ref AND A.CTN = B.CTN
WHERE Txn_ProductType = 'Price Plan'

UPDATE #Order_Summary
SET Migration_Type = 'None'
WHERE Migration_Type IS NULL



UPDATE #Order_Summary
SET Price_Plan_Lifetime_Cost = (Price_Plan_Lifetime_Cost * Contract_GROSS_Period_Total),
Extras_Lifetime_Cost = Extras_Lifetime_Cost * Contract_GROSS_Period_Total
WHERE Contract_Gross_Period_Total > 0


-- CREATE TABLE #DealType (
-- Order_Ref  [varchar] (50) COLLATE Latin1_General_CI_AS NULL,
-- CTN  [varchar] (50) COLLATE Latin1_General_CI_AS NULL,
-- Deal_Type  [varchar] (50) COLLATE Latin1_General_CI_AS NULL)
-- 
-- INSERT INTO #DealType
-- SELECT Order_Ref, CTN, 'Contract'
-- FROM tbl_Transaction_Current
-- WHERE Txn_ProductType = 'Contract'
-- GROUP BY Order_Ref, CTN
-- 
-- INSERT INTO #DealType
-- SELECT A.Order_Ref, A.CTN,  'Handset Sale'
-- FROM tbl_Transaction_Current A LEFT OUTER JOIN #DealType B
-- ON A.Order_Ref = B.Order_Ref AND A.CTN = B.CTN
-- WHERE Txn_ProductType = 'Handset'
-- AND Txn_Flag_E = 'New Sale'
-- AND B.CTN IS NULL
-- GROUP BY a.Order_Ref, a.CTN
-- 
-- INSERT INTO #DealType
-- SELECT A.Order_Ref, A.CTN, 'Handset_Exchange'
-- FROM tbl_Transaction_Current A LEFT OUTER JOIN #DealType B
-- ON A.Order_Ref = B.Order_Ref AND A.CTN = B.CTN
-- WHERE Txn_ProductType = 'Handset'-- 
-- AND Txn_Flag_E = 'Exchange'
-- AND B.CTN IS NULL
-- GROUP BY a.Order_Ref, a.CTN
-- 
-- INSERT INTO #DealType
-- SELECT A.Order_Ref, A.CTN, A.Txn_ProductType
-- FROM tbl_Transaction_Current A LEFT OUTER JOIN #DealType B
-- ON A.Order_Ref = B.Order_Ref AND A.CTN = B.CTN
-- WHERE Txn_ProductType = 'Price Plan'
-- AND B.CTN IS NULL
-- GROUP BY a.Order_Ref, a.CTN, a.Txn_ProductType
-- 
-- INSERT INTO #DealType
-- SELECT A.Order_Ref, A.CTN, 'Additional Service'
-- FROM tbl_Transaction_Current A LEFT OUTER JOIN #DealType B
-- ON A.Order_Ref = B.Order_Ref AND A.CTN = B.CTN
-- WHERE Txn_ProductType = 'Extras'
-- AND B.CTN IS NULL
-- GROUP BY a.Order_Ref, a.CTN
-- 
-- 
-- INSERT INTO #DealType
-- SELECT A.Order_Ref, A.CTN, 'Discount'
-- FROM tbl_Transaction_Current A LEFT OUTER JOIN #DealType B
-- ON A.Order_Ref = B.Order_Ref
-- WHERE Txn_ProductType LIKE '%Discount%'
-- AND B.Order_Ref IS NULL
-- GROUP BY a.Order_Ref, a.CTN
-- 
-- INSERT INTO #DealType
-- SELECT A.Order_Ref, A.CTN, 'Credit'
-- FROM tbl_Transaction_Current A LEFT OUTER JOIN #DealType B
-- ON A.Order_Ref = B.Order_Ref
-- WHERE Txn_ProductType LIKE '%Credit%'
-- AND B.Order_Ref IS NULL
-- GROUP BY a.Order_Ref, a.CTN

--UPDATE #Order_Summary
--SET Order_Hierachy = B.Deal_Type
--FROM #Order_Summary A JOIN #DealType B
--ON A.Order_Ref = B.Order_Ref
-- 
-- UPDATE #Order_Summary
-- SET Order_Hierachy = 'Contract'
-- WHERE Contract_NET_Volume > 0
-- 
-- UPDATE #Order_Summary
-- SET Order_Hierachy = 'Other Sale'
-- WHERE Order_Hierachy IS NULL


--Standard Metrics Exceptions (A-F - Commitment Exceptions)

UPDATE #Order_Summary
Set
[Exception_A_Flag] = multiChange, 
[Exception_B_Flag] = EarlyUG, 
[Exception_C_Flag] = CBack, 
[Exception_D_Flag] = Comm_CBack, 
[Exception_E_Flag] = CBack_Comm, 
[Exception_F_Flag] = Comm_Reduced
from #Order_Summary A
join [Tbl_Exceptions_Commitment] B
on B.Memo_CTN = A.CTN
and B.Memo_Date = A.Order_Date

--Standard Metrics Exceptions (G-I - Discounts & SUI Overides)



UPDATE #Order_Summary
Set
[Exception_G_Flag] = 1 
from #Order_Summary A
join [tbl_Exceptions_DiscountNoEndDate] B
on B.BAN = A.BAN
and B.Memo_Date = A.Order_Date

UPDATE #Order_Summary
Set
[Exception_H_Flag] = 1 
from #Order_Summary A
join [tbl_Exceptions_DiscountTypeUsage] B
on B.BAN = A.BAN
and B.Memo_Date = A.Order_Date

UPDATE #Order_Summary
Set
[Exception_I_Flag] = 1
from #Order_Summary A
join [tbl_Exceptions_DiscountValue] B
on B.BAN = A.BAN
and B.Memo_Date = A.Order_Date


/* Removed as tbl_Exceptions_SUIOverrides is not current, has a max date of 02/11/2007 - DH 23/07/2008

UPDATE #Order_Summary
Set
[Exception_J_Flag] = 1 
from #Order_Summary A
join [tbl_Exceptions_SUIOverrides] B
on B.CTN = A.CTN
and B.Quote_Date = A.Order_Date

*/


--CTR2 NEW SQL Added (RH - 2007-09-01)

Update #Order_Summary

set ctr_deal_type = 
CASE		WHEN order_type = 'Acquisition' THEN 'ACQ'
		WHEN order_type = 'Retention' THEN 'RET'
		ELSE 'RET'
END,
ctr_matrix_type = 
CASE		WHEN isnull(Channel,'X') = 'Online' THEN 'Online'
		WHEN isnull(department,'X') = 'Direct Sales Inbound' THEN 'Online'
		ELSE 'Core'
END,

Extras_Family_CTR_Volume = Family_Flag,
CTR_VMI_Flag = VMI_Flag,
CTR_ICS_Flag = ICS,
CTR_6MHP_Flag = Six_MHP_Extras,
CTR_3MHP_Flag = Three_MHP_Extras,
Extras_Minutes_Bundle_CTR = Fifty_PC_Extra,
CTR_10PC_Flag = Ten_PC_Off_Extras,
Extras_FLR_CTR = Three_MHP_Extras + Six_MHP_Extras,
Extras_STC_CTR = STC_Extras,
--SMS_Extras --Added later
CTR_Bonus_Available = 
CASE	WHEN Order_type = 'Acquisition' And Contract_NET_Volume = 0 then 0
	WHEN Order_type = 'Retention' And Contract_Gross_Volume = 0 then 0
	WHEN Order_type = 'Retention' And Contract_Gross_Volume = 1 then 4
	WHEN isnull(Channel,'X') = 'Online' THEN Elig_Extras_TSOL
	WHEN isnull(department,'X') = 'Direct Sales Inbound' THEN Elig_Extras_TSOL
	ELSE Elig_Extras_Retail_Indirect END,
Extras_Content_CTR = MTV_Ent_Extras + MTV_News_Extras,
CTR_Contract_Len = Contract_Len,
CTR_PricePoint = Gross_LR_Incl_VAT,
CTR_Unlim_LL_Extras = Unlim_LL_Extras,
CTR_Unlim_SMS_Extras  = Unlim_SMS_Extras,
CTR_FWC_Extras = FWC_Extras,
CTR_Plan_SMS = INCL_SMS,
CTR_SIMONLY_Flag = SIMONLY_Flag,
CTR_MealDeal_Flag = MealDeal_Flag,
CTR_Incl_Mins = Incl_MINS,
CTR_Extras_In_Plan = Extras_In_Pplan,
CTR_Elig_SMS = Elig_SMS
--CTR_Addnl_SMS --Added Later
FROM #Order_Summary A
JOIN dbo.Tbl_CTR2_Plan_Ref B
ON A.Primary_Soc = B.Price_Plan_Code


exec dbo.SP_CTR_Extras_SM

Update #Order_Summary
set
migration_type = replace(migration_type,'To Legacy','to CTR') ,
CTR_Type = 'CTR'
Where (Ctr_deal_type in ('Ret', 'Acq') or CTR_Type = 'CTR')




UPDATE #Order_Summary
SET Extras_Volume_CTR = 
(
Extras_Text_Bundle_CTR +
CTR_Unlim_SMS_Extras + 
Extras_Minutes_Bundle_CTR +
Extras_Content_CTR + 
Extras_STC_CTR + 
CTR_10PC_Flag +
CTR_3MHP_Flag +
CTR_6MHP_Flag + 
CTR_Unlim_LL_Extras + 
CTR_FWC_Extras
)
 - Extras_STC_Paid

UPDATE #Order_Summary
set CTR_Bonus_Used = Extras_Volume_CTR

Declare @UpdateDate datetime
Declare @UpdateDate1 datetime

Set @UpdateDate = (Select Min(Order_Date) from #Order_Summary)
Set @UpdateDate1 = (Select Max(Order_Date) from #Order_Summary)

EXEC MiStandardmetrics.dbo.SpCreate_CTR2_ProdSummary @UpdateDate, @UpdateDate1

--CTR2 NEW SQL END

--LEGACY CTR SQL PLACEHOLDER
--LEGACY CTR SQL PLACEHOLDER
--LEGACY CTR SQL PLACEHOLDER
--LEGACY CTR SQL PLACEHOLDER
--LEGACY CTR SQL PLACEHOLDER


--COMMERCIAL COSTS
--====================FIRST COMMERCIAL COST UPDATE

CREATE TABLE #Commercial_Costs_PP (
Order_Reference VARCHAR(50) NULL,
CTN VARCHAR(50) NULL,
ProductType VARCHAR(50),
Recurring_Cost MONEY NULL,
Fixed_Cost MONEY NULL)

INSERT INTO #Commercial_Costs_PP
SELECT A.Order_Ref, A.CTN, A.txn_ProductType, B.Recurring, B.Fixed
FROM tbl_Transaction_Current A LEFT OUTER JOIN mireferencetables.dbo.tbl_SOC_Commercial_Costs B
ON A.txn_ProductCode = B.SOC
WHERE A.txn_ProductType IN ('Price Plan')
AND A.Dl_Flag_B NOT LIKE '%STCT%'
AND A.Txn_ProductCode NOT LIKE A.Dl_Flag_A
AND Order_Date > '11-30-2008'
--DH7
AND A.Order_Date Between b.Eff_Date and Exp_Date


CREATE TABLE #CommercialCostFinalPP (
Order_Ref VARCHAR(50) NULL,
CTN VARCHAR(50) NULL,
Txn_Product_Type VARCHAR(50) NULL,
Txn_Fixed_Cost MONEY NULL,
Txn_Recurring_Cost MONEY NULL)

INSERT INTO #CommercialCostFinalPP
SELECT Order_Reference, CTN, ProductType, 
SUM(Fixed_Cost),SUM(Recurring_Cost)
FROM #Commercial_Costs_PP
GROUP BY Order_Reference, CTN, ProductType


UPDATE #Order_Summary
SET Price_Plan_Commercial_ST_Cost = B.Txn_Fixed_Cost,
Price_Plan_Commercial_LT_Cost = B.Txn_Recurring_Cost
FROM #Order_Summary A JOIN #CommercialCostFinalPP B
ON A.Order_Ref = B.Order_Ref AND A.CTN = B.CTN
WHERE B.Txn_Product_Type = 'Price Plan'


CREATE TABLE #Commercial_Costs_EX (
Order_Reference VARCHAR(50) NULL,
CTN VARCHAR(50) NULL,
ProductType VARCHAR(50),
Recurring_Cost MONEY NULL,
Fixed_Cost MONEY NULL)

INSERT INTO #Commercial_Costs_EX
SELECT A.Order_Ref, A.CTN, A.txn_ProductType, B.Recurring, B.Fixed
FROM tbl_Transaction_Current A LEFT OUTER JOIN mireferencetables.dbo.tbl_SOC_Commercial_Costs B
ON A.txn_ProductCode = B.SOC
WHERE A.txn_ProductType IN ('Extras')
AND A.Order_Date > '11-30-2008'
--DH7
AND A.Order_Date Between b.Eff_Date and Exp_Date



CREATE TABLE #CommercialCostFinalEX (
Order_Ref VARCHAR(50) NULL,
CTN VARCHAR(50) NULL,
Txn_Product_Type VARCHAR(50) NULL,
Txn_Fixed_Cost MONEY NULL,
Txn_Recurring_Cost MONEY NULL)

INSERT INTO #CommercialCostFinalEX
SELECT Order_Reference, CTN, ProductType, 
SUM(Fixed_Cost),SUM(Recurring_Cost)
FROM #Commercial_Costs_EX
GROUP BY Order_Reference, CTN, ProductType


UPDATE #Order_Summary
SET Extras_Commercial_ST_Cost = B.Txn_Fixed_Cost,
Extras_Commercial_LT_Cost = B.Txn_Recurring_Cost
FROM #Order_Summary A JOIN #CommercialCostFinalEX B
ON A.Order_Ref = B.Order_Ref AND A.CTN = B.CTN
WHERE B.Txn_Product_Type = 'Extras'





UPDATE #Order_Summary
SET Agent_ID = B.Gemini_ID
FROM #Order_Summary A JOIN MIReferenceTables.dbo.tbl_agents B
ON A.Agent = B.Name
AND A.Team = B.Tm
AND A.CCManager = B.CCm
WHERE Agent_ID IS NULL


--CODE FOR BLACKBERRY STORM HANDSET SUBSIDY
--RETENTION DEALS ONLY, TO FIX PRICE AT £275


CREATE TABLE #StormSubsidy
(Order_Ref VARCHAR(100),
CTN VARCHAR(100),
Storm_Volume INT,
Storm_Cost MONEY,
Storm_Subsidy MONEY,
Total_Storm_Subsidy MONEY)

INSERT INTO #StormSubsidy (Order_Ref, CTN, Storm_Volume)
SELECT Order_Ref, CTN, Handset_Volume
FROM #Order_Summary
WHERE Primary_Handset LIKE '%Storm%'
--AND Order_Date = '11-19-2008'

DECLARE @CurrStormPrice AS MONEY
SET @CurrStormPrice = (SELECT Max(Current_Price) FROM MIReporting.dbo.New_Handset_Table WHERE Handset_Description LIKE '%Storm%' AND Handset_Description NOT LIKE '%Return%' AND Product_Type = 'Handset')

UPDATE #StormSubsidy
SET Storm_Cost = @CurrStormPrice

--Updated to £295 from £275 
UPDATE #StormSubsidy
SET Storm_Subsidy = Storm_Cost - 295
WHERE Storm_Cost > 295

UPDATE #StormSubsidy 
SET Total_Storm_Subsidy = Storm_Volume * Storm_Subsidy


UPDATE #Order_Summary
SET Handset_Subsidy = ISNULL(Total_Storm_Subsidy,0)
FROM #Order_Summary A JOIN #StormSubsidy B
ON A.Order_Ref = B.Order_Ref AND A.CTN = B.CTN
WHERE Order_Type = 'Retention'
AND Business_Unit = 'CBU'
AND Channel IN ('Call Centre - Sales','Call Centre - Customer','Call Centre - Credit','Retail','Call Centre - Other')

--CODE FOR NOKIA N96 HANDSET SUBSIDY
--RETENTION DEALS ONLY, TO FIX PRICE AT £275


CREATE TABLE #N96Subsidy
(Order_Ref VARCHAR(100),
CTN VARCHAR(100),
N96_Volume INT,
N96_Cost MONEY,
N96_Subsidy MONEY,
Total_N96_Subsidy MONEY)

INSERT INTO #N96Subsidy (Order_Ref, CTN, N96_Volume)
SELECT Order_Ref, CTN, Handset_Volume
FROM #Order_Summary
WHERE Primary_Handset LIKE '%N96%'
AND Primary_Handset NOT LIKE '%Return%'
--AND Order_Date = '11-19-2008'

DECLARE @CurrN96Price AS MONEY
SET @CurrN96Price = (SELECT Max(Current_Price) FROM MIReporting.dbo.New_Handset_Table WHERE Handset_Description LIKE '%N96%' AND Handset_Description NOT LIKE '%Return%' AND Product_Type = 'Handset')

UPDATE #N96Subsidy
SET N96_Cost = @CurrN96Price

--Updated to £295 from £275 
UPDATE #N96Subsidy
SET N96_Subsidy = N96_Cost - 275
WHERE N96_Cost > 275

UPDATE #N96Subsidy 
SET Total_N96_Subsidy = N96_Volume * N96_Subsidy


UPDATE #Order_Summary
SET Handset_Subsidy = ISNULL(Total_N96_Subsidy,0)
FROM #Order_Summary A JOIN #N96Subsidy B
ON A.Order_Ref = B.Order_Ref AND A.CTN = B.CTN
WHERE Order_Type = 'Retention'
AND Business_Unit = 'CBU'
AND Channel IN ('Call Centre - Sales','Call Centre - Customer','Call Centre - Credit','Retail','Call Centre - Other')

--INSERT INTO tbl_Transaction_CurrentSummary
--SELECT * FROM #Order_Summary

-- 
 DELETE FROM tbl_Transaction_Summary
 WHERE Order_Date IN (SELECT Order_Date FROM #Order_Summary)
-- -- 
INSERT INTO tbl_Transaction_Summary
SELECT * FROM #Order_Summary

-- SUI completed deals reporting

/* Creates temp table to hold unique quotes for current day */

CREATE TABLE [#UniqueQuotes] (
	[Quote_ID] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
	[CTN] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
	[Status] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
	[Date] [char] (10) COLLATE Latin1_General_CI_AS NULL ,
	[Customer_Band] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
	[Investment_Value] [money] NULL ,
	[Total_Giveaway] [money] NULL ,
	[CashBack] [money] NULL ,
	[Recommitment_Period] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
	[Agent_ID] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
	[Gemini_ID] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
	[Hermes_User] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
	[Hermes_ID] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
	[Reason_Code] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
	[Reason_Description] [varchar] (100) COLLATE Latin1_General_CI_AS NULL ,
	[Auth_ID] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
	[Auth_Name] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
	[Auth_Gemini_ID] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
	[FourteenDay_ID] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
	[Quote_Date] [datetime] NULL ,
	[QSUIRIV] [float] NULL ,
	[QSUIRIVRemaining] [float] NULL ,
	[QSUIAuthCode] [varchar] (20) COLLATE Latin1_General_CI_AS NULL 
)

/* Inserts unique quotes to temp table */


INSERT INTO #UniqueQuotes
SELECT 	MAX(Quote_ID) as Quote_ID
,	CTN
,	Status
,	Date
,	Customer_Band
,	Investment_Value
,	Total_Giveaway
,	Cashback
,	Recommitment_Period
,	Agent_ID
,	Gemini_ID
,	Hermes_User
,	Hermes_ID
,	Reason_Code
,	Reason_Description
,	Auth_ID
,	Auth_Name
,	Auth_Gemini_ID
,	FourteenDay_ID
,	MAX(Quote_Date) as Quote_Date
,	QSUIRIV
,	QSUIRIVRemaining
,	QSUIAuthCode
FROM SPSVRSQL01.MIReporting.dbo.TPC_QuoteSummary_Current
GROUP BY
	QSUIRIV
,	QSUIRIVRemaining
,	QSUIAuthCode
,	CTN
,	Status
,	[Date]
,	Customer_Band
,	Investment_Value
,	Total_Giveaway
,	CashBack
,	Recommitment_Period
,	Agent_ID
,	Gemini_ID
,	Hermes_User
,	Hermes_ID
,	Reason_Code
,	Reason_Description
,	Auth_ID
,	Auth_Name
,	Auth_Gemini_ID
,	FourteenDay_ID


/* Creates daily temp table */

CREATE TABLE [#CompletedDeals] (
	[Order_Date] [datetime] NULL ,
	[OrderWeek] [datetime] NULL ,
	[OrderMonth] [varchar] (250) COLLATE Latin1_General_CI_AS NULL ,
	[Site] [varchar] (250) COLLATE Latin1_General_CI_AS NULL ,
	[Department] [varchar] (250) COLLATE Latin1_General_CI_AS NULL ,
	[TPCAgent] [varchar] (250) COLLATE Latin1_General_CI_AS NULL ,
	[CustomerBand] [int] NULL ,
	[VolQuotes] [int] NULL ,
	[VolContracts] [int] NULL ,
	[HW_Loss] [money] NULL ,
	[AT_Cost] [money] NULL ,
	[STC_Cost] [money] NULL ,
	[COS] [money] NULL ,
	[RIV] [money] NULL,
	[12mths] [int] NULL ,
	[18Mths] [int] NULL ,
	[24Mths] [int] NULL ,
	[VolETC] [int] NULL ,
	[OverrideAmount] [money] NULL ,
	[Override] [int] NULL 
)


/* Imports SUI Completed Deals to daily temp table */

INSERT	#CompletedDeals
	(Order_Date, OrderWeek, OrderMonth, Site, Department, TPCAgent, CustomerBand, VolQuotes, VolContracts, HW_Loss, AT_Cost, [COS], RIV, [12Mths], [18Mths], [24Mths], [VolETC], OverrideAmount, [Override])

SELECT 	tqc.Quote_Date as Order_Date,
	tdh.Wk_Comm_Sun as OrderWeek,
	tdh.H_Year_Month as OrderMonth,
	ta.Site,
	ta.Department,
	ta.[Name] as TPCAgent,
	tqc.Customer_Band as CustomerBand,
	count(tqc.Quote_ID) as VolQuotes,
	VolContracts = 0,
	HW_Loss = 0,
	AT_Cost = 0,
	[COS] = 0,
	RIV = 0,
	[12Mths] = 0,
	[18Mths] = 0,
	[24mths] = 0,
	VolETC = 0,
	OverrideAmount = 0,
	[Override] = 0
FROM 	#UniqueQuotes tqc
JOIN	
	SPSVRSQL01.MIReferenceTables.dbo.tbl_Date_HouseKeeping tdh
	ON	tqc.Quote_Date = tdh.H_Date
JOIN	
	SPSVRSQL01.MIReferenceTables.dbo.tbl_Agents as ta
	ON	tqc.Gemini_ID = ta.Gemini_ID
LEFT OUTER JOIN 	#Order_Summary os
	ON tqc.CTN = os.CTN
	AND tqc.Quote_Date = os.Order_Date
	AND tqc.Gemini_ID = os.Agent_ID
WHERE	tqc.Quote_ID IS NOT NULL
GROUP BY tqc.Quote_Date,
	tdh.Wk_Comm_Sun,
	tdh.H_Year_Month,
	ta.Site,
	ta.Department,
	ta.[Name],
	tqc.Customer_Band

UNION

SELECT	tqc.Quote_Date as Order_Date,
	tdh.Wk_Comm_Sun as OrderWeek,
	tdh.H_Year_Month as OrderMonth,
	ta.Site,
	ta.Department,
	ta.[Name] as TPCAgent,
	tqc.Customer_Band as CustomerBand,
	VolQuotes = 0,
	sum(Contract_Gross_Volume) as VolContracts,
	(sum((Handset_Cost+Accessory_Cost+Credits_Cost_total)-(Handset_Revenue+Accessory_Revenue)) +
	sum((SIM_Card_Cost+PAYT_SIM_Card_Cost+Delivery_Charge_Cost)-(SIM_Card_Revenue+PAYT_SIM_Card_Revenue+Delivery_Charge_Revenue))) as HW_Loss,
	(sum(isnull(Price_Plan_Commercial_ST_Cost,0)+isnull(Extras_Commercial_ST_Cost,0))+sum((isnull(Price_Plan_Commercial_LT_Cost,0)+isnull(Extras_Commercial_LT_Cost,0))*isnull(Contract_GROSS_Period_Total,0)) +
	Sum(Discounts_Cost)) as AT_Cost,
	(sum((Handset_Cost+Accessory_Cost+Credits_Cost_total)-(Handset_Revenue+Accessory_Revenue)) +
	sum((SIM_Card_Cost+PAYT_SIM_Card_Cost+Delivery_Charge_Cost)-(SIM_Card_Revenue+PAYT_SIM_Card_Revenue+Delivery_Charge_Revenue))) +
	(sum(isnull(Price_Plan_Commercial_ST_Cost,0)+isnull(Extras_Commercial_ST_Cost,0))+sum((isnull(Price_Plan_Commercial_LT_Cost,0)+isnull(Extras_Commercial_LT_Cost,0))*isnull(Contract_GROSS_Period_Total,0)) +
	Sum(Discounts_Cost)) as [COS],
	Sum(SUI_RIV) as RIV,
	sum(case when Contract_GROSS_Period_Total <= 17 then 1
	else 0 end) as [12Mths],
	sum(case when Contract_GROSS_Period_Total BETWEEN 18 AND 23 then 1
	else 0 end) as [18Mths],
	sum(case when Contract_GROSS_Period_Total >= 24 then 1
	else 0 end) as [24Mths],
	sum(case when Contract_GROSS_Period_Total >= 18 then 1
	else 0 end) as [VolETC],
	OverrideAmount = CASE WHEN 
	(sum((Handset_Cost+Accessory_Cost+Credits_Cost_total)-(Handset_Revenue+Accessory_Revenue)) +
	sum((SIM_Card_Cost+PAYT_SIM_Card_Cost+Delivery_Charge_Cost)-(SIM_Card_Revenue+PAYT_SIM_Card_Revenue+Delivery_Charge_Revenue))) +
	(sum(isnull(Price_Plan_Commercial_ST_Cost,0)+isnull(Extras_Commercial_ST_Cost,0))+sum((isnull(Price_Plan_Commercial_LT_Cost,0)+isnull(Extras_Commercial_LT_Cost,0))*isnull(Contract_GROSS_Period_Total,0)) +
	Sum(Discounts_Cost)) >	Sum(SUI_RIV)
	AND tqc.Reason_Code IS NOT NULL
			THEN
	(sum((Handset_Cost+Accessory_Cost+Credits_Cost_total)-(Handset_Revenue+Accessory_Revenue)) +
	sum((SIM_Card_Cost+PAYT_SIM_Card_Cost+Delivery_Charge_Cost)-(SIM_Card_Revenue+PAYT_SIM_Card_Revenue+Delivery_Charge_Revenue))) +
	(sum(isnull(Price_Plan_Commercial_ST_Cost,0)+isnull(Extras_Commercial_ST_Cost,0))+sum((isnull(Price_Plan_Commercial_LT_Cost,0)+isnull(Extras_Commercial_LT_Cost,0))*isnull(Contract_GROSS_Period_Total,0)) +
	Sum(Discounts_Cost)) -	Sum(SUI_RIV)
			ELSE
	0
	END,
	[Override] = CASE WHEN 
	(sum((Handset_Cost+Accessory_Cost+Credits_Cost_total)-(Handset_Revenue+Accessory_Revenue)) +
	sum((SIM_Card_Cost+PAYT_SIM_Card_Cost+Delivery_Charge_Cost)-(SIM_Card_Revenue+PAYT_SIM_Card_Revenue+Delivery_Charge_Revenue))) +
	(sum(isnull(Price_Plan_Commercial_ST_Cost,0)+isnull(Extras_Commercial_ST_Cost,0))+sum((isnull(Price_Plan_Commercial_LT_Cost,0)+isnull(Extras_Commercial_LT_Cost,0))*isnull(Contract_GROSS_Period_Total,0)) +
	Sum(Discounts_Cost)) >	Sum(SUI_RIV)
	AND tqc.Reason_Code IS NOT NULL
			THEN 1
			ELSE 0
		END	
FROM 	#UniqueQuotes tqc
JOIN	
	SPSVRSQL01.MIReferenceTables.dbo.tbl_Date_HouseKeeping tdh
	ON	tqc.Quote_Date = tdh.H_Date
JOIN	
	SPSVRSQL01.MIReferenceTables.dbo.tbl_Agents as ta
	ON	tqc.Gemini_ID = ta.Gemini_ID
LEFT OUTER JOIN 	#Order_Summary os
	ON tqc.CTN = os.CTN
	AND tqc.Quote_Date = os.Order_Date
	AND tqc.Gemini_ID = os.Agent_ID
WHERE	os.Contract_GROSS_Period_Total > '11'
	AND os.Order_Date IS NOT NULL
	AND os.Order_Type = 'Retention'
	AND os.Transaction_Type = 'Contract'
	AND tqc.Status = 'A'
GROUP BY tqc.Quote_Date,
	tdh.Wk_Comm_Sun,
	tdh.H_Year_Month,
	ta.Site,
	ta.Department,
	ta.[Name],
	tqc.Customer_Band,
	tqc.Reason_Code

/* Inserts daily temp data to main table */

DELETE FROM SPSVRMI01.MIOutputs.dbo.tblCompletedDeals
WHERE Order_Date IN (SELECT Order_Date FROM #CompletedDeals)

INSERT	SPSVRMI01.MIOutputs.dbo.tblCompletedDeals
(Order_Date, OrderWeek, OrderMonth, Site, Department, TPCAgent, CustomerBand, VolQuotes, VolContracts, HW_Loss, AT_Cost,
[COS], RIV, [12Mths], [18Mths], [24Mths], [VolETC], OverrideAmount, [Override])
SELECT Order_Date,
	OrderWeek,
	OrderMonth,
	Site,
	Department,
	TPCAgent,
	CustomerBand,
	VolQuotes,
	VolContracts,
	HW_Loss,
	AT_Cost,
	[COS],
	RIV,
	[12Mths],
	[18Mths],
	[24mths],
	VolETC,
	OverrideAmount,
	[Override]
FROM #CompletedDeals

-- End of SUI completed deals reporting


--Exceptions Reporting (SR 30/07)
DELETE FROM tblContractClockbackExceptions
WHERE Order_Date IN (SELECT Order_Date FROM #Order_Summary)

INSERT INTO tblContractClockbackExceptions
SELECT CTN, Order_Date, Contract_Gross_Volume, Exception_A_Flag, Exception_B_Flag,
Exception_C_Flag,Exception_D_Flag,Exception_E_Flag,Exception_F_Flag 
FROM #Order_Summary
WHERE (Exception_A_Flag = 1 OR Exception_B_Flag = 1 OR Exception_C_Flag = 1
OR Exception_D_Flag = 1 OR Exception_E_Flag = 1 OR Exception_F_Flag = 1)


EXEC MIReferenceTables.dbo.spAdminMessages 'SuperUser','Transaction Summary Success'


























































































GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

