--These are SQL Server scripts so will need adapting for EDW/Teradata with the NO FALLBACK , NO BEFORE JOURNAL, NO AFTER JOURNAL, CHECKSUM = DEFAULT type options
    
--Contract Table, rename is as you wish just let me know!

CREATE TABLE [tbl_Contracts_History] (
	[BAN] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
	[CTN] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
	[Dealer_Code] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
	[Agent_ID] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
	[Order_Date] [datetime] NULL ,
	[New_Contract_Start_Date] [datetime] NULL ,
	[New_Contract_End_Date] [datetime] NULL ,
	[Old_Contract_Start_Date] [datetime] NULL ,
	[Old_Contract_End_Date] [datetime] NULL ,
	[Connection_Date] [datetime] NULL ,
	[Gross_Contract_Length] [int] NULL ,
	[Net_Contract_Length] [int] NULL ,
	[Lost_Months] [int] NULL ,
	[ResetType] [int] NULL ,
	[Contract_Type] [varchar] (50) COLLATE Latin1_General_CI_AS NULL 
) ON [PRIMARY]
GO


--Price Plan table, as above

CREATE TABLE [tbl_PricePlans_History] (
	[Memo_BAN] [varchar] (12) COLLATE Latin1_General_CI_AS NULL ,
	[Memo_CTN] [varchar] (12) COLLATE Latin1_General_CI_AS NULL ,
	[Memo_Agent_ID] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
	[Memo_Date] [datetime] NULL ,
	[Prev_SOC_Code] [varchar] (100) COLLATE Latin1_General_CI_AS NULL ,
	[Prev_Start_Date] [datetime] NULL ,
	[Prev_End_Date] [datetime] NULL ,
	[Prev_Rate] [money] NULL ,
	[New_SOC_Code] [varchar] (100) COLLATE Latin1_General_CI_AS NULL ,
	[New_Start_Date] [datetime] NULL ,
	[New_End_Date] [datetime] NULL ,
	[New_Rate] [money] NULL ,
	[Dealer_Code] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
	[Order_Type] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
	[Prev_Type] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
	[New_Type] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
	[Date_Loaded] [datetime] NOT NULL 
) ON [PRIMARY]
GO


--Additional Services / Extras

CREATE TABLE [tbl_Additional_Services_History] (
	[BAN] [varchar] (15) COLLATE Latin1_General_CI_AS NULL ,
	[CTN] [varchar] (15) COLLATE Latin1_General_CI_AS NULL ,
	[Memo_Type] [varchar] (5) COLLATE Latin1_General_CI_AS NULL ,
	[Memo_Agent_ID] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
	[Memo_System_Text] [varchar] (250) COLLATE Latin1_General_CI_AS NULL ,
	[Memo_Date] [datetime] NULL ,
	[Effective_From] [datetime] NULL ,
	[Effective_To] [datetime] NULL ,
	[SOC_Code] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
	[SOC_Description] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
	[SOC_Type] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
	[SOC_Group] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
	[Activity_Type] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
	[Dealer_Code] [varchar] (50) COLLATE Latin1_General_CI_AS NULL 
) ON [PRIMARY]
GO



--Discounts

CREATE TABLE [tbl_Discounts_History] (
	[Memo_BAN] [varchar] (15) COLLATE Latin1_General_CI_AS NULL ,
	[CTN] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
	[Customer_Type] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
	[Memo_Agent_ID] [varchar] (100) COLLATE Latin1_General_CI_AS NULL ,
	[Agent] [varchar] (100) COLLATE Latin1_General_CI_AS NULL ,
	[Team] [varchar] (100) COLLATE Latin1_General_CI_AS NULL ,
	[CCM] [varchar] (100) COLLATE Latin1_General_CI_AS NULL ,
	[Department] [varchar] (100) COLLATE Latin1_General_CI_AS NULL ,
	[Site] [varchar] (100) COLLATE Latin1_General_CI_AS NULL ,
	[Reporting_Group] [varchar] (100) COLLATE Latin1_General_CI_AS NULL ,
	[Memo_Date] [datetime] NULL ,
	[SOC_Code] [varchar] (15) COLLATE Latin1_General_CI_AS NULL ,
	[SOC_Description] [varchar] (50) COLLATE Latin1_General_CI_AS NULL ,
	[SOC_Type] [varchar] (25) COLLATE Latin1_General_CI_AS NULL ,
	[Line_Rental] [money] NULL ,
	[Revenue_Code] [varchar] (25) COLLATE Latin1_General_CI_AS NULL ,
	[Discount_Percent] [money] NULL ,
	[Discount_Amount] [money] NULL ,
	[Start_Date] [datetime] NULL ,
	[End_Date] [datetime] NULL ,
	[Cancelled_Date] [datetime] NULL ,
	[Discount_Level] [varchar] (15) COLLATE Latin1_General_CI_AS NULL ,
	[Discount_Period] [int] NULL ,
	[Total_Discount_Value] [money] NULL ,
	[Monthly_Discount_Value] [money] NULL ,
	[Max_Discount_Value] [money] NULL ,
	[Max_Monthly_Discount_Value] [money] NULL ,
	[ValidSOC] [varchar] (5) COLLATE Latin1_General_CI_AS NULL ,
	[ValidDiscount] [varchar] (5) COLLATE Latin1_General_CI_AS NULL ,
	[Contract_Length] [int] NULL ,
	[Max_Value] [money] NULL ,
	[Max_Value_B] [money] NULL ,
	[Contract_Flag] [varchar] (50) COLLATE Latin1_General_CI_AS NULL 
) ON [PRIMARY]
GO




