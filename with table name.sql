SELECT  
    CONVERT(DATE, SIM.SaleDate) AS Sale_Date,
    SIM.InvoiceNo,
    '(' + SC.Cust_Code + ') - ' + SC.Cust_Name AS SalesCust_Name,

    STUFF((
        SELECT ', ' + CAST(EM.Full_Name AS VARCHAR(MAX))
        FROM dbo.Employee_Master EM
        WHERE EM.Emp_ID IN (
            SELECT SalesMan_ID
            FROM dbo.SalesMan_Master
            WHERE Is_Status = 1
              AND SIM.Cust_ID IN (SELECT * FROM dbo.HDSplit(CustomerIDs))
        )
        FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, '') AS SalesMan_Under_Party,
        
    IFM.TagNo,
    CONVERT(DATE, ISNULL(IFM.Entry_Date, KGI.Entry_Date)) AS TagDate,
    CONVERT(DATE, ISNULL(KG_OM.Order_Date, ISNULL(OLD_OM.Order_Date, OM.Order_Date))) AS Order_Date,
    CONVERT(DATE, ISNULL(KG_OM.Due_Date, ISNULL(OLD_OM.Due_Date, OM.Due_Date))) AS Due_Date,
    NULLIF(
        ISNULL(
            ISNULL(KG_Gen.P_Due_Date, KG_OD.P_Due_Date),
            ISNULL(OLD_Gen.P_Due_Date, ISNULL(GOD.P_Due_Date, OD.P_Due_Date))
        ),
        '1900-01-01'
    ) AS P_Due_Date,

    ISNULL(KG_OM.Order_No, ISNULL(OLD_OM.Order_No, OM.Order_No)) AS Order_No,
    ISNULL(KG_OM.MainPONo, ISNULL(OLD_OM.MainPONo, OM.MainPONo)) AS MainPONo,
    ISNULL(KG_OM.Order_Type, ISNULL(OLD_OM.Order_Type, OM.Order_Type)) AS Order_Type,
    ISNULL(KG_OM.Order_Bulk, ISNULL(OLD_OM.Order_Bulk, OM.Order_Bulk)) AS Order_Bulk,

    '(' + OC.Cust_Code + ') - ' + OC.Cust_Name AS Order_Party,
    MC.Category_Name,
    MSC.Sub_Category_Name,
    MDS.DesignSetting_Name AS Setting_Name,
    IFM.StyleBio,

    SIIM.Gross_Weigth AS Gross_Wt,
    MM.Metal_Type AS Touch,
    saleGold.GWt,
    saleGold.CWt,
    saleDiamond.DWt,
    saleStone.SWt,

    CONVERT(NUMERIC(30,2), SIRM.Stone_Amt * SIM.Currency_Rate) AS Stone_Amt,
    CONVERT(NUMERIC(30,2), Diam_Amt * SIM.Currency_Rate) AS Diam_Amt,
    CONVERT(NUMERIC(30,2), GoldAmt * SIM.Currency_Rate) AS GoldAmt,
    CONVERT(NUMERIC(30,2), ChainAmt * SIM.Currency_Rate) AS ChainAmt,
    CONVERT(NUMERIC(30,2), GoldLabourAmt * SIM.Currency_Rate) AS GoldLabourAmt,
    CONVERT(NUMERIC(30,2), ChainLabourAmt * SIM.Currency_Rate) AS ChainLabourAmt,
    CONVERT(NUMERIC(30,2), Certi_Charge * SIM.Currency_Rate) AS Certi_Charge,

    ISNULL(Cust_GoldWt, 0) AS Cust_GoldWt,
    ISNULL(Cust_ChainWt, 0) AS Cust_ChainWt,
    ISNULL(Cust_DiamWt, 0) AS Cust_DiamWt,
    ISNULL(Cust_StoneWt, 0) AS Cust_StoneWt,

    CASE 
        WHEN EXISTS (
            SELECT 1 FROM Repair_Item_FinishGood_Master R
            WHERE R.Finish_Id = IFM.Finish_Id
        ) THEN 'Yes'
        ELSE 'No'
    END AS Repair,

    CONVERT(NUMERIC(30,2), SIRM.Total_Amt * SIM.Currency_Rate) AS Sale_TagAmt,

    BM.Branch_ShortName AS Sale_Branch,
    CITY.City_Name,
    ST.State_Name,
    CM.CurrencyName AS Currency_Name,
    SIM.Currency_Rate,
    U.Full_Name AS Entry_By

FROM dbo.Sales_Invoice_Item_Master_New SIIM
LEFT JOIN dbo.Sales_Invoice_Rate_Master_New SIRM ON SIRM.SaleInvoice_ID = SIIM.SaleInvoice_ID
LEFT JOIN dbo.Sales_Invoice_Master_New SIM ON SIIM.Sale_ID = SIM.Sale_ID
LEFT JOIN dbo.Customer_Approve_Master_New CAM ON SIM.Approve_ID = CAM.Approve_ID
LEFT JOIN dbo.Item_FinishGood_Master IFM ON IFM.TagNo = SIIM.TagNo
LEFT JOIN JwelexKGGK..Item_FinishGood_Master KGI ON KGI.TagNo = IFM.TagNo AND IFM.TagNo LIKE 'K%'

LEFT JOIN dbo.Item_FinishGood_Master OG ON OG.TagNo = LEFT(IFM.TagNo, 8) AND IFM.TagNo LIKE 'G%'
LEFT JOIN JwelexKGGK..Item_FinishGood_Master OK ON OK.TagNo = LEFT(IFM.TagNo, 8) AND IFM.TagNo LIKE 'K%'

LEFT JOIN dbo.Production_History_Master JP ON JP.TagNo = OG.TagNo AND JP.Entry_Type = 'Production'
LEFT JOIN JwelexMfg23..Production_History_Master GKP ON GKP.TagNo = OG.TagNo AND GKP.Entry_Type = 'Production' AND ISNULL(JP.Finish_Id, 0) = 0
LEFT JOIN JwelexKGGK..Production_History_Master KP ON KP.TagNo = OK.TagNo AND KP.Entry_Type = 'Production'

LEFT JOIN dbo.Batch_Master JB ON JB.Batch_Id = JP.Batch_Id
LEFT JOIN JwelexMfg23..Batch_Master OldJB ON OldJB.Batch_Id = GKP.Batch_Id AND ISNULL(JP.Batch_Id, 0) = 0
LEFT JOIN JwelexKGGK..Batch_Master KB ON KB.Batch_Id = KP.Batch_Id AND ISNULL(JP.Batch_Id, 0) = 0 AND ISNULL(GKP.Batch_Id, 0) = 0

LEFT JOIN dbo.Order_Detail OD ON OD.Order_Detail_Id = JB.Order_Detail_Id
LEFT JOIN dbo.Order_Master OM ON OD.Order_Id = OM.Order_Id
LEFT JOIN dbo.Gen_Order_Detail GOD ON OD.Order_Detail_Id = GOD.Order_Detail_Id

LEFT JOIN JwelexMfg23..Order_Detail OLD_OD ON OLD_OD.Order_Detail_Id = OldJB.Order_Detail_Id
LEFT JOIN JwelexMfg23..Order_Master OLD_OM ON OLD_OD.Order_Id = OLD_OM.Order_Id
LEFT JOIN JwelexMfg23..Gen_Order_Detail OLD_Gen ON OLD_OD.Order_Detail_Id = OLD_Gen.Order_Detail_Id

LEFT JOIN JwelexKGGK..Order_Detail KG_OD ON KG_OD.Order_Detail_Id = KB.Order_Detail_Id
LEFT JOIN JwelexKGGK..Order_Master KG_OM ON KG_OD.Order_Id = KG_OM.Order_Id
LEFT JOIN JwelexKGGK..Gen_Order_Detail KG_Gen ON KG_OD.Order_Detail_Id = KG_Gen.Order_Detail_Id

LEFT JOIN dbo.M_Customer OC ON OC.Cust_ID = ISNULL(KG_OM.Party_Id, ISNULL(OLD_OM.Party_Id, OM.Party_Id))

LEFT JOIN dbo.Branch_Master BM ON BM.Branch_ID = SIM.Branch_ID
LEFT JOIN dbo.M_Metal MM ON MM.Metal_ID = IFM.Metal_ID
LEFT JOIN dbo.M_Category MC ON MC.Category_ID = IFM.Category_Id
LEFT JOIN dbo.M_Sub_Category MSC ON MSC.Sub_Category_ID = IFM.Sub_Category_Id
LEFT JOIN dbo.M_Design_Setting MDS ON MDS.Design_ID = IFM.Setting_Id
LEFT JOIN dbo.M_Customer SC ON SC.Cust_ID = SIM.Cust_ID
LEFT JOIN dbo.M_City CITY ON CITY.City_Id = SC.City_ID
LEFT JOIN dbo.M_State ST ON ST.State_Id = SC.State_ID
LEFT JOIN dbo.CurrencyMst CM ON CM.CurrencyId = SIM.Currency_Id
LEFT JOIN dbo.Employee_Master U ON U.Emp_ID = SIM.Entry_By

-- OUTER APPLY blocks (same logic, with alias correction)
OUTER APPLY (
    SELECT 
        SaleInvoice_ID,
        ISNULL(SUM(CASE WHEN (MC1_Wt - MC1_CustWt) < 0 THEN 0 ELSE (MC1_Wt - MC1_CustWt) END), 0) AS GWt,
        ISNULL(SUM(CASE WHEN (CHMC1_Wt - CHMC1_CustWt) < 0 THEN 0 ELSE (CHMC1_Wt - CHMC1_CustWt) END), 0) AS CWt,
        SUM(MC1_GoldAmt) AS GoldAmt,
        SUM(CHMC1_ChainAmt) AS ChainAmt,
        SUM(MC1_LabourAmt + MC1_WastageAmt) AS GoldLabourAmt,
        SUM(CHMC1_LabourAmt + CH1_WastageAmt) AS ChainLabourAmt
    FROM Sales_Invoice_Rate_Detail_New
    WHERE SaleInvoice_ID = SIIM.SaleInvoice_ID
    GROUP BY SaleInvoice_ID
) AS saleGold

OUTER APPLY (
    SELECT SaleInvoice_ID, ISNULL(SUM(Weigth), 0) AS DWt
    FROM Sales_Invoice_Item_Detail_New
    WHERE Meterial = 'Diamond' AND SaleInvoice_ID = SIIM.SaleInvoice_ID
    GROUP BY SaleInvoice_ID
) AS saleDiamond

OUTER APPLY (
    SELECT SaleInvoice_ID, ISNULL(SUM(Weigth), 0) AS SWt
    FROM Sales_Invoice_Item_Detail_New
    WHERE Meterial = 'Stone' AND SaleInvoice_ID = SIIM.SaleInvoice_ID
    GROUP BY SaleInvoice_ID
) AS saleStone

OUTER APPLY (
    SELECT SaleInvoice_ID, SUM(ISNULL(Cust_Weight, 0)) AS Cust_GoldWt
    FROM Sales_Invoice_Item_Detail_New
    LEFT JOIN M_Metal ON M_Metal.Metal_ID = Sales_Invoice_Item_Detail_New.Purity_ID
    WHERE Metal_Name = 'METAL' AND Meterial = 'Gold' AND SaleInvoice_ID = SIIM.SaleInvoice_ID
    GROUP BY SaleInvoice_ID
) AS itemGold

OUTER APPLY (
    SELECT SaleInvoice_ID, SUM(ISNULL(Cust_Weight, 0)) AS Cust_ChainWt
    FROM Sales_Invoice_Item_Detail_New
    LEFT JOIN M_Metal ON M_Metal.Metal_ID = Sales_Invoice_Item_Detail_New.Purity_ID
    WHERE Metal_Name = 'CHAIN' AND Meterial = 'Gold' AND SaleInvoice_ID = SIIM.SaleInvoice_ID
    GROUP BY SaleInvoice_ID
) AS itemChain

OUTER APPLY (
    SELECT SaleInvoice_ID, ISNULL(SUM(Cust_Weight), 0) AS Cust_DiamWt
    FROM Sales_Invoice_Item_Detail_New
    WHERE Meterial = 'Diamond' AND SaleInvoice_ID = SIIM.SaleInvoice_ID
    GROUP BY SaleInvoice_ID
) AS itemDiamond

OUTER APPLY (
    SELECT SaleInvoice_ID, ISNULL(SUM(Cust_Weight), 0) AS Cust_StoneWt
    FROM Sales_Invoice_Item_Detail_New
    WHERE Meterial = 'Stone' AND SaleInvoice_ID = SIIM.SaleInvoice_ID
    GROUP BY SaleInvoice_ID
) AS itemStone

WHERE CONVERT(DATE, SIM.SaleDate) BETWEEN {{Start_Date}} AND {{End_Date}}

ORDER BY SIM.SaleDate DESC;
