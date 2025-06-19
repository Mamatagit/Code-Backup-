total pcs
diamond
gold
for perticuler daye



--CREATE PROCEDURE [dbo].[Get_ProductionSummaryReport]                                                                            
Declare @Branch_Id INT = 1,
@Setting_Id VARCHAR(MAX) = '1,2,3,4,5,6,7',  
@FromDate AS DATE = '2025-03-18',                                                                            
@ToDate AS DATE ='2025-03-18',  
@TagNo AS VARCHAR(50)=''  
--AS                                                                            
BEGIN            
 
IF OBJECT_ID(N'tempdb..#tempProduction1') IS NOT NULL DROP TABLE #tempProduction1    
IF OBJECT_ID(N'tempdb..#tempVoucher') IS NOT NULL DROP TABLE #tempVoucher    
IF OBJECT_ID(N'tempdb..#tempProduction') IS NOT NULL DROP TABLE #tempProduction    
  
IF OBJECT_ID(N'tempdb..#tempTagVoucherReverse') IS NOT NULL DROP TABLE #tempTagVoucherReverse  
IF OBJECT_ID(N'tempdb..#tempTagRepair') IS NOT NULL DROP TABLE #tempTagRepair    
IF OBJECT_ID(N'tempdb..#tempTagRepFinal') IS NOT NULL DROP TABLE #tempTagRepFinal    
IF OBJECT_ID(N'tempdb..#tempCustTagRepair') IS NOT NULL DROP TABLE #tempCustTagRepair    
IF OBJECT_ID(N'tempdb..#tempVoucherReverse') IS NOT NULL DROP TABLE #tempVoucherReverse                                          
IF OBJECT_ID(N'tempdb..#tempCustTagRepFinal') IS NOT NULL DROP TABLE #tempCustTagRepFinal    
            
IF OBJECT_ID(N'tempdb..#tempMetalProduction1') IS NOT NULL DROP TABLE #tempMetalProduction1    
IF OBJECT_ID(N'tempdb..#tempMetalVoucher') IS NOT NULL DROP TABLE #tempMetalVoucher    
IF OBJECT_ID(N'tempdb..#tempMetalProductionFinal') IS NOT NULL DROP TABLE #tempMetalProductionFinal    
            
IF OBJECT_ID(N'tempdb..#tempDiamProduction1') IS NOT NULL DROP TABLE #tempDiamProduction1                                          
IF OBJECT_ID(N'tempdb..#tempDiamVoucher') IS NOT NULL DROP TABLE #tempDiamVoucher      
IF OBJECT_ID(N'tempdb..#tempDiamond') IS NOT NULL DROP TABLE #tempDiamond    
            
IF OBJECT_ID(N'tempdb..#tempMetalTagRepair') IS NOT NULL DROP TABLE #tempMetalTagRepair     
IF OBJECT_ID(N'tempdb..#tempMetalTagRepFinal') IS NOT NULL DROP TABLE #tempMetalTagRepFinal    
IF OBJECT_ID(N'tempdb..#tempDiamTagRepair') IS NOT NULL DROP TABLE #tempDiamTagRepair     
IF OBJECT_ID(N'tempdb..#tempDiamTagRepairVoucher') IS NOT NULL DROP TABLE #tempDiamTagRepairVoucher    
IF OBJECT_ID(N'tempdb..#tempTagRepairDiamond') IS NOT NULL DROP TABLE #tempTagRepairDiamond    
             
IF OBJECT_ID(N'tempdb..#tempMetalTagVoucherReverse') IS NOT NULL DROP TABLE #tempMetalTagVoucherReverse  
  
--- Tagging Detail                                                       
SELECT * INTO #tempProduction1 FROM (                                      
SELECT CONVERT(DATE,Entry_Date) Entry_Date, Finish_Id ,ISNULL(Gold_Wt,0) + ISNULL(Chain_Wt ,0) + ISNULL(DiaGram ,0) + ISNULL(StoneGram ,0) + ISNULL(Other_Wt ,0) AS Gross_Wt,                                       
ISNULL(Gold_Wt,0) Gold_Wt,ISNULL(GoldPure_Wt,0) GoldPure_Wt ,ISNULL(Chain_Wt ,0) Chain_Wt ,ISNULL(ChainPure_Wt,0) ChainPure_Wt ,                                      
ISNULL(Dia_Wt ,0) Dia_Wt, Isnull(DiaPcs ,0) DiaPcs ,ISNULL(DiaGram ,0) DiaGram ,ISNULL(Stone_Wt ,0) Stone_Wt ,ISNULL(StonePcs ,0) StonePcs ,                                      
ISNULL(StoneGram ,0) StoneGram ,ISNULL(Other_Wt ,0) Other_Wt ,ISNULL(OtherPcs ,0) OtherPcs   FROM (                                      
SELECT Finish_Id,CONVERT(DATE,Entry_Date) AS Entry_Date,mGold.Gold_Wt,mGold.GoldPure_Wt,mChain.Chain_Wt,mChain.ChainPure_Wt,mDia.Dia_Wt,mDia.DiaPcs,mDia.DiaGram,                                      
mStone.Stone_Wt,mStone.StonePcs,mStone.StoneGram,mOther.Other_Wt,mOther.OtherPcs                                                                       
FROM dbo.Production_History_Master WITH (NOLOCK)           
OUTER APPLY (                                      
SELECT SUM(Weight) AS Gold_Wt,SUM(Pure_Wt) AS GoldPure_Wt FROM dbo.Production_History_Detail WITH (NOLOCK)                                      
LEFT JOIN dbo.M_Metal WITH (NOLOCK) ON dbo.M_Metal.Metal_ID =  Production_History_Detail.Purity_Id                                      
WHERE Production_History_Detail.Product_Id = dbo.Production_History_Master.Product_Id   
  AND Production_History_Detail.Finish_Id = dbo.Production_History_Master.Finish_Id AND Material_Type = 'Metal' AND Metal_Name = 'METAL'                                      
) AS mGold                                      
OUTER APPLY (                                      
SELECT SUM(Weight) AS Chain_Wt,SUM(Pure_Wt) AS ChainPure_Wt FROM dbo.Production_History_Detail WITH (NOLOCK)                                      
LEFT JOIN dbo.M_Metal WITH (NOLOCK) ON dbo.M_Metal.Metal_ID =  Production_History_Detail.Purity_Id                                      
WHERE Production_History_Detail.Product_Id = dbo.Production_History_Master.Product_Id   
 AND Production_History_Detail.Finish_Id = dbo.Production_History_Master.Finish_Id AND Material_Type = 'Metal' AND Metal_Name = 'CHAIN'                                      
) AS mChain                                      
OUTER APPLY (                                      
SELECT SUM(Weight) AS Dia_Wt,SUM(Pcs) AS DiaPcs,ROUND(SUM(Weight)/5,3) AS DiaGram FROM dbo.Production_History_Detail WITH (NOLOCK)                                       
WHERE Production_History_Detail.Product_Id = dbo.Production_History_Master.Product_Id   
 AND Production_History_Detail.Finish_Id = dbo.Production_History_Master.Finish_Id AND Material_Type = 'Diamond'                                      
) AS mDia                                      
OUTER APPLY (                                      
SELECT SUM(Weight) AS Stone_Wt,SUM(Pcs) AS StonePcs,ROUND(SUM(Weight)/5,3) AS StoneGram FROM dbo.Production_History_Detail WITH (NOLOCK)                                       
WHERE Production_History_Detail.Product_Id = dbo.Production_History_Master.Product_Id   
 AND Production_History_Detail.Finish_Id = dbo.Production_History_Master.Finish_Id AND Material_Type = 'Stone'                                      
) AS mStone                                                                         
OUTER APPLY (                                      
SELECT SUM(Weight) AS Other_Wt,SUM(Pcs) AS OtherPcs FROM dbo.Production_History_Detail WITH (NOLOCK)                                       
WHERE Production_History_Detail.Product_Id = dbo.Production_History_Master.Product_Id   
 AND Production_History_Detail.Finish_Id = dbo.Production_History_Master.Finish_Id AND Material_Type = 'Other'                                      
) AS mOther                                 
WHERE Entry_Type = 'Production' AND (Production_History_Master.Branch_Id=@Branch_Id OR @Branch_Id = -1) AND CONVERT(DATE,Entry_Date) BETWEEN @FromDate AND @ToDate                                      
) AS m1                               
) AS mproduction         
 order by mproduction.Finish_Id                           
                 
                                    
SELECT * INTO #tempVoucher FROM (                                  
SELECT CONVERT(DATE,Entry_Date) Entry_Date, Finish_Id ,(ISNULL(Gold_Wt,0) + ISNULL(Chain_Wt ,0) + ISNULL(DiaGram ,0) + ISNULL(StoneGram ,0) + ISNULL(Other_Wt ,0))*-1 AS Gross_Wt,                                      
ISNULL(Gold_Wt,0)*-1 Gold_Wt,ISNULL(GoldPure_Wt,0)*-1 GoldPure_Wt ,ISNULL(Chain_Wt ,0)*-1 Chain_Wt ,ISNULL(ChainPure_Wt,0)*-1 ChainPure_Wt ,                           
ISNULL(Dia_Wt ,0)*-1 Dia_Wt, Isnull(DiaPcs ,0)*-1 DiaPcs ,ISNULL(DiaGram ,0)*-1 DiaGram ,ISNULL(Stone_Wt ,0)*-1 Stone_Wt ,ISNULL(StonePcs ,0)*-1 StonePcs ,                                      
ISNULL(StoneGram ,0)*-1 StoneGram ,ISNULL(Other_Wt ,0)*-1 Other_Wt ,ISNULL(OtherPcs ,0)*-1 OtherPcs ,Entry_Type,Batch_Id                              
FROM (                                      
SELECT Finish_Id,CONVERT(DATE,Entry_Date) AS Entry_Date,mGold.Gold_Wt,mGold.GoldPure_Wt,mChain.Chain_Wt,mChain.ChainPure_Wt,mDia.Dia_Wt,mDia.DiaPcs,mDia.DiaGram,                                      
mStone.Stone_Wt,mStone.StonePcs,mStone.StoneGram,mOther.Other_Wt,mOther.OtherPcs ,Entry_Type,Batch_Id                                          
FROM dbo.Production_History_Master WITH (NOLOCK)                                      
OUTER APPLY (                                      
SELECT SUM(Weight) AS Gold_Wt,SUM(Pure_Wt) AS GoldPure_Wt FROM dbo.Production_History_Detail WITH (NOLOCK)                                      
LEFT JOIN dbo.M_Metal WITH (NOLOCK) ON dbo.M_Metal.Metal_ID =  Production_History_Detail.Purity_Id                                      
WHERE Production_History_Detail.Product_Id = dbo.Production_History_Master.Product_Id   
 AND Production_History_Detail.Finish_Id = dbo.Production_History_Master.Finish_Id AND Material_Type = 'Metal' AND Metal_Name = 'METAL'                                      
) AS mGold                                      
OUTER APPLY (                                      
SELECT SUM(Weight) AS Chain_Wt,SUM(Pure_Wt) AS ChainPure_Wt FROM dbo.Production_History_Detail WITH (NOLOCK)                                      
LEFT JOIN dbo.M_Metal WITH (NOLOCK) ON dbo.M_Metal.Metal_ID =  Production_History_Detail.Purity_Id                                      
WHERE Production_History_Detail.Product_Id = dbo.Production_History_Master.Product_Id   
  AND Production_History_Detail.Finish_Id = dbo.Production_History_Master.Finish_Id AND Material_Type = 'Metal' AND Metal_Name = 'CHAIN'                                      
) AS mChain                                      
OUTER APPLY (                                      
SELECT SUM(Weight) AS Dia_Wt,SUM(Pcs) AS DiaPcs,ROUND(SUM(Weight)/5,3) AS DiaGram FROM dbo.Production_History_Detail WITH (NOLOCK)                                       
WHERE Production_History_Detail.Product_Id = dbo.Production_History_Master.Product_Id   
  AND Production_History_Detail.Finish_Id = dbo.Production_History_Master.Finish_Id AND Material_Type = 'Diamond'                                      
) AS mDia                                      
OUTER APPLY (                                      
SELECT SUM(Weight) AS Stone_Wt,SUM(Pcs) AS StonePcs,ROUND(SUM(Weight)/5,3) AS StoneGram FROM dbo.Production_History_Detail WITH (NOLOCK)                                       
WHERE Production_History_Detail.Product_Id = dbo.Production_History_Master.Product_Id   
  AND Production_History_Detail.Finish_Id = dbo.Production_History_Master.Finish_Id AND Material_Type = 'Stone'                                      
) AS mStone                                                                         
OUTER APPLY (                                      
SELECT SUM(Weight) AS Other_Wt,SUM(Pcs) AS OtherPcs FROM dbo.Production_History_Detail WITH (NOLOCK)                                       
WHERE Production_History_Detail.Product_Id = dbo.Production_History_Master.Product_Id   
  AND Production_History_Detail.Finish_Id = dbo.Production_History_Master.Finish_Id AND Material_Type = 'Other'                                      
) AS mOther                  
WHERE Entry_Type = 'Voucher Entry' AND (Production_History_Master.Branch_Id=@Branch_Id OR @Branch_Id = -1) AND CONVERT(DATE,Entry_Date) BETWEEN @FromDate AND @ToDate                                                                       
) AS m2                                      
                                  
) AS mFinal                               
                            
                            
SELECT * INTO #tempProduction From (                            
SELECT * FROM #tempProduction1                              
--UNION ALL                            
                            
--SELECT t2.Entry_Date,t2.Finish_Id,t2.Gross_Wt,t2.Gold_Wt,t2.GoldPure_Wt,t2.Chain_Wt,t2.ChainPure_wt,t2.Dia_Wt,t2.DiaPcs,t2.DiaGram,t2.Stone_Wt,t2.stonepcs,                            
--t2.StoneGram,t2.other_wt,t2.otherpcs FROM #tempProduction1 t1                            
--INNER JOIN #tempVoucher t2 ON t1.Finish_id=t2.Finish_id AND t1.Entry_date=t2.entry_date                             
--WHERE                              
--t2.entry_type='Voucher Entry'                              
) mmfinalll                            
                  
  
                                      
SELECT Item_FinishGood_Master.TagNo,dbo.Item_FinishGood_Master.Finish_Id,Category_Name,dbo.M_Customer.Cust_Name,dbo.M_Customer.Cust_Code,xx.Cust_Name AS ORDER_Cust,  
Batch_No,Touch.Metal_Type AS Touch,Item_FinishGood_Master.StyleBio,dbo.Batch_Master.Total_Loss ,  
SUM(tp.Gross_Wt) AS Gross_Wt,SUM(tp.Dia_Wt) Dia_Wt,Sum(DiaGram) Dia_Gram,SUM(StoneGram) Stone_Gram,SUM(DiaPcs) AS Dia_Pcs,  
SUM(tp.Gold_Wt) AS Gold_Wt,SUM(tp.Chain_Wt) AS Chain_Wt,SUM(GoldPure_Wt) + SUM(ChainPure_Wt) AS Pure_Wt,  
SUM(tp.Gold_Wt) + SUM(tp.Chain_Wt) - SUM(GoldPure_Wt) - SUM(ChainPure_Wt) AS Alloy,SUM(tp.Stone_Wt) As Stone_Wt ,SUM(tp.Other_Wt) As Other_Wt ,  
CASE WHEN dbo.Item_FinishGood_Master.Is_Approve = 1 THEN 'Approve'  WHEN dbo.Item_FinishGood_Master.Is_Issue_To_Lab = 1 THEN 'IssueToLab'  
WHEN dbo.Item_FinishGood_Master.Is_item = 1 THEN 'Item'  WHEN dbo.Item_FinishGood_Master.Is_Locker = 1 THEN 'Locker'  
WHEN dbo.Item_FinishGood_Master.Is_Marge = 1 THEN 'Merge'  WHEN dbo.Item_FinishGood_Master.Is_Repair = 1 THEN 'Repair'  
WHEN dbo.Item_FinishGood_Master.Is_Sales = 1  AND dbo.Item_FinishGood_Master.Sold_Repair = 0  THEN 'Sale'  WHEN dbo.Item_FinishGood_Master.Is_SalesMan = 1 THEN 'Salesman Transfer'  
WHEN dbo.Item_FinishGood_Master.Is_Split= 1 THEN 'Split'  WHEN dbo.Item_FinishGood_Master.Status = 1 THEN 'Branch Transfer' ELSE 'STOCK' END AS [Status],  
ISNULL(Order_Detail.PO_No,Item_FinishGood_Master.PO_No) AS PO_No  
FROM #tempProduction AS tp  
LEFT JOIN dbo.Item_FinishGood_Master WITH (NOLOCK) ON dbo.Item_FinishGood_Master.Finish_Id = tp.Finish_Id                                                                          
LEFT JOIN dbo.Batch_Master WITH (NOLOCK) ON dbo.Batch_Master.Batch_Id = dbo.Item_FinishGood_Master.Batch_Id  
LEFT JOIN dbo.Gen_Order_Master WITH (NOLOCK) ON dbo.Batch_Master.Gorder_Id = dbo.Gen_Order_Master.Gorder_Id                
LEFT JOIN dbo.Order_Detail WITH (NOLOCK) ON dbo.Batch_Master.Order_Detail_Id = dbo.Order_Detail.Order_Detail_Id  
LEFT JOIN dbo.M_Customer AS xx WITH (NOLOCK) ON dbo.Gen_Order_Master.Party_Id = xx.Cust_ID                
LEFT JOIN dbo.M_Metal AS Touch WITH (NOLOCK) ON Touch.Metal_ID = dbo.Item_FinishGood_Master.Metal_ID                                                                          
LEFT JOIN dbo.M_Category WITH (NOLOCK) ON dbo.M_Category.Category_ID = dbo.Item_FinishGood_Master.Category_Id                                                                          
LEFT JOIN dbo.M_Customer WITH (NOLOCK) ON dbo.M_Customer.Cust_ID = dbo.Item_FinishGood_Master.Customer_Id                               
WHERE Setting_Id IN (SELECT * FROM  dbo.HDSplit(@Setting_Id )) AND Item_FinishGood_Master.TagNo = CASE WHEN @TagNo <>'' THEN  @TagNo ELSE Item_FinishGood_Master.TagNo END      
GROUP BY Item_FinishGood_Master.TagNo,dbo.Item_FinishGood_Master.Finish_Id,Category_Name,dbo.M_Customer.Cust_Name,dbo.M_Customer.Cust_Code,xx.Cust_Name,                                                    
Batch_No,Touch.Metal_Type,Item_FinishGood_Master.StyleBio,dbo.Batch_Master.Total_Loss ,                                      
CASE WHEN dbo.Item_FinishGood_Master.Is_Approve = 1 THEN 'Approve'  WHEN dbo.Item_FinishGood_Master.Is_Issue_To_Lab = 1 THEN 'IssueToLab'                                                                             
WHEN dbo.Item_FinishGood_Master.Is_item = 1 THEN 'Item'  WHEN dbo.Item_FinishGood_Master.Is_Locker = 1 THEN 'Locker'                                                                             
WHEN dbo.Item_FinishGood_Master.Is_Marge = 1 THEN 'Merge'  WHEN dbo.Item_FinishGood_Master.Is_Repair = 1 THEN 'Repair'                                              
WHEN dbo.Item_FinishGood_Master.Is_Sales = 1  AND dbo.Item_FinishGood_Master.Sold_Repair = 0  THEN 'Sale'  WHEN dbo.Item_FinishGood_Master.Is_SalesMan = 1 THEN 'Salesman Transfer' 
WHEN dbo.Item_FinishGood_Master.Is_Split= 1 THEN 'Split' WHEN dbo.Item_FinishGood_Master.Status = 1 THEN 'Branch Transfer' ELSE 'STOCK' END,  
ISNULL(Order_Detail.PO_No,Item_FinishGood_Master.PO_No)  
HAVING SUM(tp.Gross_Wt) <> 0                               
ORDER BY RIGHT(Item_FinishGood_Master.TagNo,5) ASC                                 
                                      
                                                   
                                                
----- Tag Repair Detail     
                                                  
                                             
--SELECT * INTO #tempTagVoucherReverse FROM (                                     
--SELECT CONVERT(DATE,Entry_Date) Entry_Date, Finish_Id ,(ISNULL(Gold_Wt,0) + ISNULL(Chain_Wt ,0) + ISNULL(DiaGram ,0) + ISNULL(StoneGram ,0) + ISNULL(Other_Wt ,0)) AS Gross_Wt,                                      
--ISNULL(Gold_Wt,0) Gold_Wt,ISNULL(GoldPure_Wt,0) GoldPure_Wt ,ISNULL(Chain_Wt ,0) Chain_Wt ,ISNULL(ChainPure_Wt,0) ChainPure_Wt ,                                      
--ISNULL(Dia_Wt ,0) Dia_Wt, Isnull(DiaPcs ,0) DiaPcs ,ISNULL(DiaGram ,0) DiaGram ,ISNULL(Stone_Wt ,0) Stone_Wt ,ISNULL(StonePcs ,0) StonePcs ,                                      
--ISNULL(StoneGram ,0) StoneGram ,ISNULL(Other_Wt ,0) Other_Wt ,ISNULL(OtherPcs ,0) OtherPcs,Batch_Id                              
--FROM (                                      
--SELECT Finish_Id,CONVERT(DATE,Entry_Date) AS Entry_Date,mGold.Gold_Wt,mGold.GoldPure_Wt,mChain.Chain_Wt,mChain.ChainPure_Wt,mDia.Dia_Wt,mDia.DiaPcs,mDia.DiaGram,                                      
--mStone.Stone_Wt,mStone.StonePcs,mStone.StoneGram,mOther.Other_Wt,mOther.OtherPcs ,Entry_Type,Batch_Id                                            
--FROM dbo.Production_History_Master WITH (NOLOCK)                                      
--OUTER APPLY (                                      
--SELECT SUM(Weight) AS Gold_Wt,SUM(Pure_Wt) AS GoldPure_Wt FROM dbo.Production_History_Detail WITH (NOLOCK)                                      
--LEFT JOIN dbo.M_Metal WITH (NOLOCK) ON dbo.M_Metal.Metal_ID =  Production_History_Detail.Purity_Id                                      
--WHERE Production_History_Detail.Product_Id = dbo.Production_History_Master.Product_Id   
--  AND Production_History_Detail.Finish_Id = dbo.Production_History_Master.Finish_Id AND Material_Type = 'Metal' AND Metal_Name = 'METAL'      
--) AS mGold                                      
--OUTER APPLY (                                      
--SELECT SUM(Weight) AS Chain_Wt,SUM(Pure_Wt) AS ChainPure_Wt FROM dbo.Production_History_Detail WITH (NOLOCK)                                      
--LEFT JOIN dbo.M_Metal WITH (NOLOCK) ON dbo.M_Metal.Metal_ID =  Production_History_Detail.Purity_Id                                      
--WHERE Production_History_Detail.Product_Id = dbo.Production_History_Master.Product_Id   
--  AND Production_History_Detail.Finish_Id = dbo.Production_History_Master.Finish_Id AND Material_Type = 'Metal' AND Metal_Name = 'CHAIN'                                      
--) AS mChain                                      
--OUTER APPLY (                                      
--SELECT SUM(Weight) AS Dia_Wt,SUM(Pcs) AS DiaPcs,ROUND(SUM(Weight)/5,3) AS DiaGram FROM dbo.Production_History_Detail WITH (NOLOCK)                                       
--WHERE Production_History_Detail.Product_Id = dbo.Production_History_Master.Product_Id   
-- AND Production_History_Detail.Finish_Id = dbo.Production_History_Master.Finish_Id AND Material_Type = 'Diamond'                                      
--) AS mDia                                      
--OUTER APPLY (                                      
--SELECT SUM(Weight) AS Stone_Wt,SUM(Pcs) AS StonePcs,ROUND(SUM(Weight)/5,3) AS StoneGram FROM dbo.Production_History_Detail WITH (NOLOCK)                              
--WHERE Production_History_Detail.Product_Id = dbo.Production_History_Master.Product_Id   
-- AND Production_History_Detail.Finish_Id = dbo.Production_History_Master.Finish_Id AND Material_Type = 'Stone'                                      
--) AS mStone                                                                         
--OUTER APPLY (                                      
--SELECT SUM(Weight) AS Other_Wt,SUM(Pcs) AS OtherPcs FROM dbo.Production_History_Detail WITH (NOLOCK)                                       
--WHERE Production_History_Detail.Product_Id = dbo.Production_History_Master.Product_Id   
-- AND Production_History_Detail.Finish_Id = dbo.Production_History_Master.Finish_Id AND Material_Type = 'Other'                                      
--) AS mOther                                      
--WHERE Entry_Type = 'Voucher Reverse' AND (Production_History_Master.Branch_Id=@Branch_Id OR @Branch_Id = -1) AND CONVERT(DATE,Entry_Date) BETWEEN @FromDate AND @ToDate                                                                       
--) AS m2         
                                      
--) AS mtagVoucherReverse  
  
                                                  
--SELECT * INTO #tempTagRepair FROM (                                     
--SELECT CONVERT(DATE,Entry_Date) Entry_Date, Finish_Id ,(ISNULL(Gold_Wt,0) + ISNULL(Chain_Wt ,0) + ISNULL(DiaGram ,0) + ISNULL(StoneGram ,0) + ISNULL(Other_Wt ,0))*-1 AS Gross_Wt,           
--ISNULL(Gold_Wt,0) Gold_Wt,ISNULL(GoldPure_Wt,0) GoldPure_Wt ,ISNULL(Chain_Wt ,0) Chain_Wt ,ISNULL(ChainPure_Wt,0) ChainPure_Wt ,                                      
--ISNULL(Dia_Wt ,0) Dia_Wt, Isnull(DiaPcs ,0) DiaPcs ,ISNULL(DiaGram ,0) DiaGram ,ISNULL(Stone_Wt ,0) Stone_Wt ,ISNULL(StonePcs ,0) StonePcs ,                                      
--ISNULL(StoneGram ,0) StoneGram ,ISNULL(Other_Wt ,0) Other_Wt ,ISNULL(OtherPcs ,0) OtherPcs,Batch_Id                              
--FROM (                                      
--SELECT Finish_Id,CONVERT(DATE,Entry_Date) AS Entry_Date,mGold.Gold_Wt,mGold.GoldPure_Wt,mChain.Chain_Wt,mChain.ChainPure_Wt,mDia.Dia_Wt,mDia.DiaPcs,mDia.DiaGram,                                      
--mStone.Stone_Wt,mStone.StonePcs,mStone.StoneGram,mOther.Other_Wt,mOther.OtherPcs ,Entry_Type,Batch_Id                                            
--FROM dbo.Production_History_Master WITH (NOLOCK)                                      
--OUTER APPLY (                                      
--SELECT SUM(Weight) AS Gold_Wt,SUM(Pure_Wt) AS GoldPure_Wt FROM dbo.Production_History_Detail WITH (NOLOCK)                                      
--LEFT JOIN dbo.M_Metal WITH (NOLOCK) ON dbo.M_Metal.Metal_ID =  Production_History_Detail.Purity_Id                                      
--WHERE Production_History_Detail.Product_Id = dbo.Production_History_Master.Product_Id   
-- AND Production_History_Detail.Finish_Id = dbo.Production_History_Master.Finish_Id AND Material_Type = 'Metal' AND Metal_Name = 'METAL'      
--) AS mGold                                      
--OUTER APPLY (                                      
--SELECT SUM(Weight) AS Chain_Wt,SUM(Pure_Wt) AS ChainPure_Wt FROM dbo.Production_History_Detail WITH (NOLOCK)                                      
--LEFT JOIN dbo.M_Metal WITH (NOLOCK) ON dbo.M_Metal.Metal_ID =  Production_History_Detail.Purity_Id                                      
--WHERE Production_History_Detail.Product_Id = dbo.Production_History_Master.Product_Id   
-- AND Production_History_Detail.Finish_Id = dbo.Production_History_Master.Finish_Id AND Material_Type = 'Metal' AND Metal_Name = 'CHAIN'                                      
--) AS mChain                                      
--OUTER APPLY (                                      
--SELECT SUM(Weight) AS Dia_Wt,SUM(Pcs) AS DiaPcs,ROUND(SUM(Weight)/5,3) AS DiaGram FROM dbo.Production_History_Detail WITH (NOLOCK)                                       
--WHERE Production_History_Detail.Product_Id = dbo.Production_History_Master.Product_Id   
-- AND Production_History_Detail.Finish_Id = dbo.Production_History_Master.Finish_Id AND Material_Type = 'Diamond'                                      
--) AS mDia                                      
--OUTER APPLY (                               
--SELECT SUM(Weight) AS Stone_Wt,SUM(Pcs) AS StonePcs,ROUND(SUM(Weight)/5,3) AS StoneGram FROM dbo.Production_History_Detail WITH (NOLOCK)                              
--WHERE Production_History_Detail.Product_Id = dbo.Production_History_Master.Product_Id   
-- AND Production_History_Detail.Finish_Id = dbo.Production_History_Master.Finish_Id AND Material_Type = 'Stone'                                      
--) AS mStone                                                                         
--OUTER APPLY (                                      
--SELECT SUM(Weight) AS Other_Wt,SUM(Pcs) AS OtherPcs FROM dbo.Production_History_Detail WITH (NOLOCK)                                       
--WHERE Production_History_Detail.Product_Id = dbo.Production_History_Master.Product_Id   
-- AND Production_History_Detail.Finish_Id = dbo.Production_History_Master.Finish_Id AND Material_Type = 'Other'                                      
--) AS mOther                                      
--WHERE Entry_Type = 'Repair' AND (Production_History_Master.Branch_Id=@Branch_Id OR @Branch_Id = -1) AND CONVERT(DATE,Entry_Date) BETWEEN @FromDate AND @ToDate                                                                       
--) AS m2                                      
             
--) AS mtagrepair                                                      
             
                            
--SELECT * INTO #tempTagRepFinal From (  
--SELECT * FROM #tempTagVoucherReverse  
--UNION ALL                            
--SELECT * FROM #tempTagRepair                      
--UNION ALL                            
                            
--SELECT t1.Entry_Date,t1.Finish_Id,t1.Gross_Wt,t1.Gold_Wt,t1.GoldPure_Wt,t1.Chain_Wt,t1.ChainPure_wt,t1.Dia_Wt,t1.DiaPcs,t1.DiaGram,t1.Stone_Wt,t1.stonepcs,                            
--t1.StoneGram,t1.other_wt,t1.otherpcs,t1.Batch_Id FROM #tempVoucher t1  
--INNER JOIN #tempTagRepair t2 ON t1.Finish_id=t2.Finish_id AND t1.Entry_date=t2.entry_date  
--INNER JOIN #tempTagVoucherReverse t3 ON t1.Finish_id=t3.Finish_id AND t1.Entry_date=t3.entry_date                            
--WHERE t1.entry_type='Voucher Entry'  
--) mtagfinal                            
                                        
                            
--  SELECT Item_FinishGood_Master.TagNo,dbo.Item_FinishGood_Master.Finish_Id,TblRepairID.Repair_Id,Category_Name,Cust_Name,Cust_Code,                                                      
--Batch_No,Touch.Metal_Type AS Touch,Item_FinishGood_Master.StyleBio,dbo.Batch_Master.Total_Loss ,                                       
--SUM(tp.Gross_Wt) AS Gross_Wt,SUM(tp.Dia_Wt) Dia_Wt,Sum(DiaGram) Dia_Gram,SUM(StoneGram) Stone_Gram,SUM(DiaPcs) AS Dia_Pcs,                                                      
--SUM(tp.Gold_Wt) AS Gold_Wt,SUM(tp.Chain_Wt) AS Chain_Wt,SUM(GoldPure_Wt) + SUM(ChainPure_Wt) AS Pure_Wt,                                      
--SUM(tp.Gold_Wt) + SUM(tp.Chain_Wt) - SUM(GoldPure_Wt) - SUM(ChainPure_Wt) AS Alloy,SUM(tp.Stone_Wt) As Stone_Wt ,SUM(tp.Other_Wt) As Other_Wt ,                                                                                          
--CASE WHEN dbo.Item_FinishGood_Master.Is_Approve = 1 THEN 'Approve'  WHEN dbo.Item_FinishGood_Master.Is_Issue_To_Lab = 1 THEN 'IssueToLab'                                               
--WHEN dbo.Item_FinishGood_Master.Is_item = 1 THEN 'Item'  WHEN dbo.Item_FinishGood_Master.Is_Locker = 1 THEN 'Locker'                                                                             
--WHEN dbo.Item_FinishGood_Master.Is_Marge = 1 THEN 'Merge'  WHEN dbo.Item_FinishGood_Master.Is_Repair = 1 THEN 'Repair'                                                                             
--WHEN dbo.Item_FinishGood_Master.Is_Sales = 1  AND dbo.Item_FinishGood_Master.Sold_Repair = 0  THEN 'Sale'  WHEN dbo.Item_FinishGood_Master.Is_SalesMan = 1 THEN 'Salesman Transfer'                                                                         
--WHEN dbo.Item_FinishGood_Master.Is_Split= 1 THEN 'Split'  WHEN dbo.Item_FinishGood_Master.Status = 1 THEN 'Branch Transfer' ELSE 'STOCK' END AS [Status]                                       
--FROM #tempTagRepFinal AS tp                                      
--LEFT JOIN dbo.Item_FinishGood_Master WITH (NOLOCK) ON dbo.Item_FinishGood_Master.Finish_Id = tp.Finish_Id                                                                          
--LEFT JOIN dbo.Batch_Master WITH (NOLOCK) ON dbo.Batch_Master.Batch_Id = dbo.Item_FinishGood_Master.Batch_Id                                                                
--LEFT JOIN dbo.M_Metal AS Touch WITH (NOLOCK) ON Touch.Metal_ID = dbo.Item_FinishGood_Master.Metal_ID                                                
--LEFT JOIN dbo.M_Category WITH (NOLOCK) ON dbo.M_Category.Category_ID = dbo.Item_FinishGood_Master.Category_Id                                                                          
--LEFT JOIN dbo.M_Customer WITH (NOLOCK) ON dbo.M_Customer.Cust_ID = dbo.Item_FinishGood_Master.Customer_Id           
--OUTER APPLY(SELECT ISNULL(Repair_Id,0) Repair_Id FROM  Repair_Item_FinishGood_Master WITH (NOLOCK) WHERE Repair_Item_FinishGood_Master.Finish_Id=dbo.Item_FinishGood_Master.Finish_Id           
--   AND Repair_Item_FinishGood_Master.Batch_Id=dbo.Item_FinishGood_Master.Batch_Id) AS TblRepairID                            
--WHERE Seting_Id IN (SELECT * FROM  dbo.HDSplit(@Setting_Id )) AND Item_FinishGood_Master.TagNo = CASE WHEN @TagNo <>'' THEN  @TagNo ELSE Item_FinishGood_Master.TagNo END                             
--GROUP BY Item_FinishGood_Master.TagNo,dbo.Item_FinishGood_Master.Finish_Id,TblRepairID.Repair_Id,Category_Name,Cust_Name,Cust_Code,                                                      
--Batch_No,Touch.Metal_Type,Item_FinishGood_Master.StyleBio,dbo.Batch_Master.Total_Loss ,      
--CASE WHEN dbo.Item_FinishGood_Master.Is_Approve = 1 THEN 'Approve'  WHEN dbo.Item_FinishGood_Master.Is_Issue_To_Lab = 1 THEN 'IssueToLab'                                     
--WHEN dbo.Item_FinishGood_Master.Is_item = 1 THEN 'Item'  WHEN dbo.Item_FinishGood_Master.Is_Locker = 1 THEN 'Locker'                                                                             
--WHEN dbo.Item_FinishGood_Master.Is_Marge = 1 THEN 'Merge'  WHEN dbo.Item_FinishGood_Master.Is_Repair = 1 THEN 'Repair'                                                                             
--WHEN dbo.Item_FinishGood_Master.Is_Sales = 1  AND dbo.Item_FinishGood_Master.Sold_Repair = 0  THEN 'Sale'  WHEN dbo.Item_FinishGood_Master.Is_SalesMan = 1 THEN 'Salesman Transfer'                                                                           
   
   
--WHEN dbo.Item_FinishGood_Master.Is_Split= 1 THEN 'Split'  WHEN dbo.Item_FinishGood_Master.Status = 1 THEN 'Branch Transfer' ELSE 'STOCK' END                                      
--HAVING SUM(tp.Gross_Wt) <> 0                                             
--ORDER BY RIGHT(TagNo,5) ASC  
                            
----SELECT Repair_Item_FinishGood_Master.TagNo,dbo.Repair_Item_FinishGood_Master.Repair_Id,dbo.Repair_Item_FinishGood_Master.Finish_Id,Category_Name,Cust_Name,                                      
----Cust_Code,Repair_Item_FinishGood_Master.Gross_Wt,Batch_No,Touch.Metal_Type AS Touch,Repair_Item_FinishGood_Master.StyleBio,dbo.Batch_Master.Total_Loss ,                                                     
----CASE WHEN Repair_Item_FinishGood_Master.Gross_Wt > 0 THEN Repair_Item_FinishGood_Master.Gross_Wt + dbo.Batch_Master.Total_Loss ELSE 0 END AS Gross_WtAdd,                                                    
----CASE WHEN Repair_Item_FinishGood_Master.Gross_Wt < 0 THEN (Repair_Item_FinishGood_Master.Gross_Wt*-1) - dbo.Batch_Master.Total_Loss ELSE 0 END AS Gross_WtLess,                                                                            
----ISNULL(Production_History_Master.Dia_Wt,0) Dia_Wt,ISNULL(CONVERT(DECIMAL(18,3),Production_History_Master.DiaGram),0) Dia_Gram,                            
----ISNULL(Production_History_Master.DiaPcs,0) AS Dia_Pcs,            
----ISNULL(Production_History_Master.Gold_Wt,0) AS Gold_Wt,ISNULL(Production_History_Master.GoldPure_Wt,0)+ISNULL(Production_History_Master.ChainPure_Wt,0) AS Pure_Wt,                            
----ISNULL(Production_History_Master.Chain_Wt,0) AS Chain_Wt,                                                                 
----ISNULL(Production_History_Master.Gold_Wt,0) + ISNULL(Production_History_Master.Chain_Wt,0) -                             
----ISNULL(Production_History_Master.GoldPure_Wt,0) - ISNULL(Production_History_Master.ChainPure_Wt,0) AS Alloy,                                                      
----Repair_Item_FinishGood_Master.Stone_Wt Stone_Wt,Round(Repair_Item_FinishGood_Master.Stone_Wt/5,3) Stone_Gram,Repair_Item_FinishGood_Master.Other_Wt,                                                          
----CASE WHEN ifm.Is_Approve = 1 THEN 'Approve'  WHEN ifm.Is_Issue_To_Lab = 1 THEN 'IssueToLab'                                                                             
----WHEN ifm.Is_item = 1 THEN 'Item'  WHEN ifm.Is_Locker = 1 THEN 'Locker'                                                                             
----WHEN ifm.Is_Marge = 1 THEN 'Merge'  WHEN ifm.Is_Repair = 1 THEN 'Repair'                                                                             
----WHEN ifm.Is_Sales = 1 AND ifm.Sold_Repair = 0 THEN 'Sale'  WHEN ifm.Is_SalesMan = 1 THEN 'Salesman Transfer'                                          
----WHEN ifm.Is_Split= 1 THEN 'Split'  WHEN ifm.Status = 1 THEN 'Branch Transfer' ELSE 'STOCK' END AS [Status]                                                                                                     
----FROM #tempTagRepFinal AS                             
----Production_History_Master WITH (NOLOCK)        
----LEFT JOIN dbo.Repair_Item_FinishGood_Master WITH (NOLOCK) ON Repair_Item_FinishGood_Master.Finish_Id = Production_History_Master.Finish_Id                                   
----AND Production_History_Master.Batch_Id = dbo.Repair_Item_FinishGood_Master.Batch_Id                               
----LEFT JOIN dbo.Batch_Master WITH (NOLOCK) ON dbo.Batch_Master.Batch_Id = dbo.Repair_Item_FinishGood_Master.Batch_Id                                                                
----LEFT JOIN dbo.Order_Detail WITH (NOLOCK) ON dbo.Order_Detail.Order_Detail_Id = dbo.Batch_Master.Order_Detail_Id                                                      
----LEFT JOIN dbo.Item_FinishGood_Master AS ifm ON ifm.Finish_Id = dbo.Repair_Item_FinishGood_Master.Finish_Id                                                                          
----LEFT JOIN dbo.M_Metal AS Touch ON Touch.Metal_ID = dbo.Repair_Item_FinishGood_Master.Metal_ID                                                                          
----LEFT JOIN dbo.M_Category ON dbo.M_Category.Category_ID = dbo.Repair_Item_FinishGood_Master.Category_Id                                                                          
----LEFT JOIN dbo.M_Customer ON dbo.M_Customer.Cust_ID = dbo.Repair_Item_FinishGood_Master.Customer_Id                                                                            
----OUTER APPLY (                                      
----SELECT SUM(Weight) AS Gold_Wt,SUM(Pure_Wt) AS GoldPure_Wt FROM dbo.Production_History_Detail WITH (NOLOCK)                                      
----LEFT JOIN dbo.M_Metal WITH (NOLOCK) ON dbo.M_Metal.Metal_ID =  Production_History_Detail.Purity_Id                                      
----WHERE Production_History_Detail.Product_Id = Production_History_Master.Product_Id AND Material_Type = 'Metal' AND Metal_Name = 'METAL'                                      
----) AS mGold                                      
----OUTER APPLY (                                      
----SELECT SUM(Weight) AS Chain_Wt,SUM(Pure_Wt) AS ChainPure_Wt FROM dbo.Production_History_Detail WITH (NOLOCK)                                      
----LEFT JOIN dbo.M_Metal WITH (NOLOCK) ON dbo.M_Metal.Metal_ID =  Production_History_Detail.Purity_Id                                      
----WHERE Production_History_Detail.Product_Id = Production_History_Master.Product_Id AND Material_Type = 'Metal' AND Metal_Name = 'CHAIN'                                      
----) AS mChain                                      
----OUTER APPLY (                                      
----SELECT SUM(Weight) AS Dia_Wt,SUM(Pcs) AS DiaPcs,ROUND(SUM(Weight)/5,3) AS DiaGram FROM dbo.Production_History_Detail WITH (NOLOCK)                                       
----WHERE Production_History_Detail.Product_Id = Production_History_Master.Product_Id AND Material_Type = 'Diamond'                               
----) AS mDia                                      
----OUTER APPLY (                                      
----SELECT SUM(Weight) AS Stone_Wt,SUM(Pcs) AS StonePcs,ROUND(SUM(Weight)/5,3) AS StoneGram FROM dbo.Production_History_Detail WITH (NOLOCK)                                       
----WHERE Production_History_Detail.Product_Id = Production_History_Master.Product_Id AND Material_Type = 'Stone'                                      
----) AS mStone                                                                         
----OUTER APPLY (                                      
----SELECT SUM(Weight) AS Other_Wt,SUM(Pcs) AS OtherPcs FROM dbo.Production_History_Detail WITH (NOLOCK)                        
----WHERE Production_History_Detail.Product_Id = Production_History_Master.Product_Id AND Material_Type = 'Other'                                      
----) AS mOther                                      
----WHERE CONVERT(DATE,Production_History_Master.Entry_Date) BETWEEN @FromDate AND @ToDate AND (dbo.Production_History_Master.Branch_Id=@Branch_Id OR @Branch_Id = -1)                                             
----AND Entry_Type = 'Repair'     
                            
                                
----GROUP BY Repair_Item_FinishGood_Master.TagNo,dbo.Repair_Item_FinishGood_Master.Repair_Id,Repair_Item_FinishGood_Master.Gross_Wt,Batch_No,                                      
----dbo.Repair_Item_FinishGood_Master.Finish_Id,Category_Name,Cust_Name,Cust_Code,Touch.Metal_Type,                                                             
----Repair_Item_FinishGood_Master.StyleBio,Production_History_Master.DiaPcs,                            
----Production_History_Master.Dia_Wt,Production_History_Master.DiaGram,                                                      
----ISNULL(Production_History_Master.Gold_Wt,0),ISNULL(Production_History_Master.Chain_Wt,0),ISNULL(Production_History_Master.GoldPure_Wt,0),                             
----ISNULL(Production_History_Master.ChainPure_Wt,0),dbo.Batch_Master.Total_Loss ,                                                      
----Repair_Item_FinishGood_Master.Stone_Wt,Repair_Item_FinishGood_Master.Other_Wt,                                                      
----CASE WHEN ifm.Is_Approve = 1 THEN 'Approve'  WHEN ifm.Is_Issue_To_Lab = 1 THEN 'IssueToLab'                                                                             
----WHEN ifm.Is_item = 1 THEN 'Item'  WHEN ifm.Is_Locker = 1 THEN 'Locker'                                                                             
----WHEN ifm.Is_Marge = 1 THEN 'Merge'  WHEN ifm.Is_Repair = 1 THEN 'Repair'                                                                             
----WHEN ifm.Is_Sales = 1 AND ifm.Sold_Repair = 0 THEN 'Sale'  WHEN ifm.Is_SalesMan = 1 THEN 'Salesman Transfer'                                                                             
----WHEN ifm.Is_Split= 1 THEN 'Split'  WHEN ifm.Status = 1 THEN 'Branch Transfer' ELSE 'STOCK' END                                
                              
                                                  
      
                                                  
----SELECT Repair_Item_FinishGood_Master.TagNo,dbo.Repair_Item_FinishGood_Master.Repair_Id,dbo.Repair_Item_FinishGood_Master.Finish_Id,Category_Name,Cust_Name,                                      
----Cust_Code,Repair_Item_FinishGood_Master.Gross_Wt,Batch_No,Touch.Metal_Type AS Touch,Repair_Item_FinishGood_Master.StyleBio,dbo.Batch_Master.Total_Loss ,                                                     
----CASE WHEN Repair_Item_FinishGood_Master.Gross_Wt > 0 THEN Repair_Item_FinishGood_Master.Gross_Wt + dbo.Batch_Master.Total_Loss ELSE 0 END AS Gross_WtAdd,                                                    
----CASE WHEN Repair_Item_FinishGood_Master.Gross_Wt < 0 THEN (Repair_Item_FinishGood_Master.Gross_Wt*-1) - dbo.Batch_Master.Total_Loss ELSE 0 END AS Gross_WtLess,                                                                            
----ISNULL(mDia.Dia_Wt,0) Dia_Wt,ISNULL(CONVERT(DECIMAL(18,3),mDia.DiaGram),0) Dia_Gram,ISNULL(mDia.DiaPcs,0) AS Dia_Pcs,                                                     
----ISNULL(mGold.Gold_Wt,0) AS Gold_Wt,ISNULL(mGold.GoldPure_Wt,0)+ISNULL(mChain.ChainPure_Wt,0) AS Pure_Wt,ISNULL(mChain.Chain_Wt,0) AS Chain_Wt,                                                                 
----ISNULL(mGold.Gold_Wt,0) + ISNULL(mChain.Chain_Wt,0) - ISNULL(mGold.GoldPure_Wt,0) - ISNULL(mChain.ChainPure_Wt,0) AS Alloy,                                                      
----Repair_Item_FinishGood_Master.Stone_Wt Stone_Wt,Round(Repair_Item_FinishGood_Master.Stone_Wt/5,3) Stone_Gram,Repair_Item_FinishGood_Master.Other_Wt,                                                                            
----CASE WHEN ifm.Is_Approve = 1 THEN 'Approve'  WHEN ifm.Is_Issue_To_Lab = 1 THEN 'IssueToLab'                                                                             
----WHEN ifm.Is_item = 1 THEN 'Item'  WHEN ifm.Is_Locker = 1 THEN 'Locker'                                                                             
----WHEN ifm.Is_Marge = 1 THEN 'Merge'  WHEN ifm.Is_Repair = 1 THEN 'Repair'                                                                             
----WHEN ifm.Is_Sales = 1 AND ifm.Sold_Repair = 0 THEN 'Sale'  WHEN ifm.Is_SalesMan = 1 THEN 'Salesman Transfer'                                                                             
----WHEN ifm.Is_Split= 1 THEN 'Split'  WHEN ifm.Status = 1 THEN 'Branch Transfer' ELSE 'STOCK' END AS [Status]                                                                                                     
----FROM dbo.Production_History_Master WITH (NOLOCK)                                      
----LEFT JOIN dbo.Repair_Item_FinishGood_Master WITH (NOLOCK) ON Repair_Item_FinishGood_Master.Finish_Id = Production_History_Master.Finish_Id                              
----AND dbo.Production_History_Master.Batch_Id = dbo.Repair_Item_FinishGood_Master.Batch_Id                                  
----LEFT JOIN dbo.Batch_Master WITH (NOLOCK) ON dbo.Batch_Master.Batch_Id = dbo.Repair_Item_FinishGood_Master.Batch_Id                                                                
----LEFT JOIN dbo.Order_Detail WITH (NOLOCK) ON dbo.Order_Detail.Order_Detail_Id = dbo.Batch_Master.Order_Detail_Id                                           
----LEFT JOIN dbo.Item_FinishGood_Master AS ifm ON ifm.Finish_Id = dbo.Repair_Item_FinishGood_Master.Finish_Id                                                                          
----LEFT JOIN dbo.M_Metal AS Touch ON Touch.Metal_ID = dbo.Repair_Item_FinishGood_Master.Metal_ID                                                                          
----LEFT JOIN dbo.M_Category ON dbo.M_Category.Category_ID = dbo.Repair_Item_FinishGood_Master.Category_Id                                                                          
----LEFT JOIN dbo.M_Customer ON dbo.M_Customer.Cust_ID = dbo.Repair_Item_FinishGood_Master.Customer_Id                          
----OUTER APPLY (                                      
----SELECT SUM(Weight) AS Gold_Wt,SUM(Pure_Wt) AS GoldPure_Wt FROM dbo.Production_History_Detail WITH (NOLOCK)                                      
----LEFT JOIN dbo.M_Metal WITH (NOLOCK) ON dbo.M_Metal.Metal_ID =  Production_History_Detail.Purity_Id                                      
----WHERE Production_History_Detail.Product_Id = dbo.Production_History_Master.Product_Id AND Material_Type = 'Metal' AND Metal_Name = 'METAL'                                      
----) AS mGold                                      
----OUTER APPLY (                                      
----SELECT SUM(Weight) AS Chain_Wt,SUM(Pure_Wt) AS ChainPure_Wt FROM dbo.Production_History_Detail WITH (NOLOCK)                                      
----LEFT JOIN dbo.M_Metal WITH (NOLOCK) ON dbo.M_Metal.Metal_ID =  Production_History_Detail.Purity_Id                                      
----WHERE Production_History_Detail.Product_Id = dbo.Production_History_Master.Product_Id AND Material_Type = 'Metal' AND Metal_Name = 'CHAIN'                                      
----) AS mChain                                      
----OUTER APPLY (                                      
----SELECT SUM(Weight) AS Dia_Wt,SUM(Pcs) AS DiaPcs,ROUND(SUM(Weight)/5,3) AS DiaGram FROM dbo.Production_History_Detail WITH (NOLOCK)                                       
----WHERE Production_History_Detail.Product_Id = dbo.Production_History_Master.Product_Id AND Material_Type = 'Diamond'                                      
----) AS mDia                                  
----OUTER APPLY (                                      
----SELECT SUM(Weight) AS Stone_Wt,SUM(Pcs) AS StonePcs,ROUND(SUM(Weight)/5,3) AS StoneGram FROM dbo.Production_History_Detail WITH (NOLOCK)                
----WHERE Production_History_Detail.Product_Id = dbo.Production_History_Master.Product_Id AND Material_Type = 'Stone'                                      
----) AS mStone                                                                         
----OUTER APPLY (                                
----SELECT SUM(Weight) AS Other_Wt,SUM(Pcs) AS OtherPcs FROM dbo.Production_History_Detail WITH (NOLOCK)                                       
----WHERE Production_History_Detail.Product_Id = dbo.Production_History_Master.Product_Id AND Material_Type = 'Other'                                      
----) AS mOther                                      
----WHERE CONVERT(DATE,dbo.Production_History_Master.Entry_Date) BETWEEN @FromDate AND @ToDate AND (dbo.Production_History_Master.Branch_Id=@Branch_Id OR @Branch_Id = -1)                                                                                       
 
  
  
  
   
   
  
    
----AND Entry_Type = 'Repair'                                      
                            
----GROUP BY Repair_Item_FinishGood_Master.TagNo,dbo.Repair_Item_FinishGood_Master.Repair_Id,Repair_Item_FinishGood_Master.Gross_Wt,Batch_No,                                      
----dbo.Repair_Item_FinishGood_Master.Finish_Id,Category_Name,Cust_Name,Cust_Code,Touch.Metal_Type,                                                             
----Repair_Item_FinishGood_Master.StyleBio,mDia.DiaPcs,mDia.Dia_Wt,mDia.DiaGram,                                                      
----ISNULL(mGold.Gold_Wt,0),ISNULL(mChain.Chain_Wt,0),ISNULL(mGold.GoldPure_Wt,0), ISNULL(mChain.ChainPure_Wt,0),dbo.Batch_Master.Total_Loss ,                                                                            
----Repair_Item_FinishGood_Master.Stone_Wt,Repair_Item_FinishGood_Master.Other_Wt,       
----CASE WHEN ifm.Is_Approve = 1 THEN 'Approve'  WHEN ifm.Is_Issue_To_Lab = 1 THEN 'IssueToLab'                      
----WHEN ifm.Is_item = 1 THEN 'Item'  WHEN ifm.Is_Locker = 1 THEN 'Locker'                                                                          
----WHEN ifm.Is_Marge = 1 THEN 'Merge'  WHEN ifm.Is_Repair = 1 THEN 'Repair'                                                                             
----WHEN ifm.Is_Sales = 1 AND ifm.Sold_Repair = 0 THEN 'Sale'  WHEN ifm.Is_SalesMan = 1 THEN 'Salesman Transfer'                                                                             
----WHEN ifm.Is_Split= 1 THEN 'Split'  WHEN ifm.Status = 1 THEN 'Branch Transfer' ELSE 'STOCK' END                              
                            
                            
                            
                            
                            
                            
            
                                                     
                                                  
----- Customer Tag Repair Detail                        
                         
                                               
--SELECT * INTO #tempCustTagRepair FROM (                                      
--SELECT CONVERT(DATE,Entry_Date) Entry_Date, Finish_Id ,(ISNULL(Gold_Wt,0) + ISNULL(Chain_Wt ,0) + ISNULL(DiaGram ,0) + ISNULL(StoneGram ,0) + ISNULL(Other_Wt ,0))*-1 AS Gross_Wt,                                      
--ISNULL(Gold_Wt,0) Gold_Wt,                        
--ISNULL(GoldPure_Wt,0) GoldPure_Wt,                        
--ISNULL(Chain_Wt ,0) Chain_Wt ,                        
--ISNULL(ChainPure_Wt,0) ChainPure_Wt ,                                      
--ISNULL(Dia_Wt ,0) Dia_Wt,                         
--Isnull(DiaPcs ,0) DiaPcs ,                        
--ISNULL(DiaGram ,0) DiaGram ,                        
--ISNULL(Stone_Wt ,0) Stone_Wt ,                        
--ISNULL(StonePcs ,0) StonePcs ,                                      
--ISNULL(StoneGram ,0) StoneGram ,                        
--ISNULL(Other_Wt ,0) Other_Wt ,                        
--ISNULL(OtherPcs ,0) OtherPcs,                        
--Batch_Id                              
--FROM (                                      
--SELECT Finish_Id,CONVERT(DATE,Entry_Date) AS Entry_Date,mGold.Gold_Wt,mGold.GoldPure_Wt,mChain.Chain_Wt,mChain.ChainPure_Wt,mDia.Dia_Wt,mDia.DiaPcs,mDia.DiaGram,                                      
--mStone.Stone_Wt,mStone.StonePcs,mStone.StoneGram,mOther.Other_Wt,mOther.OtherPcs ,Entry_Type,Batch_Id                                            
--FROM dbo.Production_History_Master WITH (NOLOCK)                                  
--OUTER APPLY (                                      
--SELECT  SUM(CASE WHEN ISNULL(Weight,0)<0 THEN 0 ELSE ISNULL(Weight,0) END) AS Gold_Wt,SUM(CASE WHEN ISNULL(Pure_Wt,0)<0 THEN 0 ELSE ISNULL(Pure_Wt,0) END) AS GoldPure_Wt FROM dbo.Production_History_Detail WITH (NOLOCK)  
--LEFT JOIN dbo.M_Metal WITH (NOLOCK) ON dbo.M_Metal.Metal_ID =  Production_History_Detail.Purity_Id                                      
--WHERE Production_History_Detail.Product_Id = dbo.Production_History_Master.Product_Id   
-- AND Production_History_Detail.Finish_Id = dbo.Production_History_Master.Finish_Id AND Material_Type = 'Metal' AND Metal_Name = 'METAL'                     
--) AS mGold                                      
--OUTER APPLY (                                      
--SELECT SUM(CASE WHEN ISNULL(Weight,0)<0 THEN 0 ELSE ISNULL(Weight,0) END) AS Chain_Wt,SUM(CASE WHEN ISNULL(Pure_Wt,0)<0 THEN 0 ELSE ISNULL(Pure_Wt,0) END) AS ChainPure_Wt FROM dbo.Production_History_Detail WITH (NOLOCK)                                    
  
  
--LEFT JOIN dbo.M_Metal WITH (NOLOCK) ON dbo.M_Metal.Metal_ID =  Production_History_Detail.Purity_Id                                      
--WHERE Production_History_Detail.Product_Id = dbo.Production_History_Master.Product_Id   
-- AND Production_History_Detail.Finish_Id = dbo.Production_History_Master.Finish_Id AND Material_Type = 'Metal' AND Metal_Name = 'CHAIN'                      
--) AS mChain                                      
--OUTER APPLY (               
--SELECT SUM(CASE WHEN ISNULL(Weight,0)<0 THEN 0 ELSE ISNULL(Weight,0) END) AS Dia_Wt,SUM(CASE WHEN ISNULL(Pcs,0)<0 THEN 0 ELSE ISNULL(Pcs,0) END) AS DiaPcs,ROUND(SUM(Weight)/5,3) AS DiaGram FROM dbo.Production_History_Detail WITH (NOLOCK)                  
  
--WHERE Production_History_Detail.Product_Id = dbo.Production_History_Master.Product_Id   
-- AND Production_History_Detail.Finish_Id = dbo.Production_History_Master.Finish_Id AND Material_Type = 'Diamond'                                      
--) AS mDia                                      
--OUTER APPLY (                                      
--SELECT SUM(CASE WHEN ISNULL(Weight,0)<0 THEN 0 ELSE ISNULL(Weight,0) END) AS Stone_Wt,SUM(CASE WHEN ISNULL(Pcs,0)<0 THEN 0 ELSE ISNULL(Pcs,0) END) AS StonePcs,ROUND(SUM(Weight)/5,3) AS StoneGram FROM dbo.Production_History_Detail WITH (NOLOCK)            
  
  
--WHERE Production_History_Detail.Product_Id = dbo.Production_History_Master.Product_Id   
-- AND Production_History_Detail.Finish_Id = dbo.Production_History_Master.Finish_Id AND Material_Type = 'Stone'                                      
--) AS mStone                                                                         
--OUTER APPLY (                                      
--SELECT SUM(CASE WHEN ISNULL(Weight,0)<0 THEN 0 ELSE ISNULL(Weight,0) END) AS Other_Wt,SUM(CASE WHEN ISNULL(Pcs,0)<0 THEN 0 ELSE ISNULL(Pcs,0) END) AS OtherPcs FROM dbo.Production_History_Detail WITH (NOLOCK)                                       
--WHERE Production_History_Detail.Product_Id = dbo.Production_History_Master.Product_Id   
-- AND Production_History_Detail.Finish_Id = dbo.Production_History_Master.Finish_Id AND Material_Type = 'Other'                                      
--) AS mOther                                      
--WHERE Entry_Type IN ('Direct Repair','Sold Repair') AND (Production_History_Master.Branch_Id=@Branch_Id OR @Branch_Id = -1) AND CONVERT(DATE,Entry_Date) BETWEEN @FromDate AND @ToDate                                                                       
--) AS m2                                      
                                      
--) AS mtagrepair                                                      
                   
                          
--SELECT * INTO #tempVoucherReverse FROM (                                      
--SELECT CONVERT(DATE,Entry_Date) Entry_Date, Finish_Id ,(ISNULL(Gold_Wt,0) + ISNULL(Chain_Wt ,0) + ISNULL(DiaGram ,0) + ISNULL(StoneGram ,0) + ISNULL(Other_Wt ,0)) AS Gross_Wt,                             
--ISNULL(Gold_Wt,0) Gold_Wt,ISNULL(GoldPure_Wt,0) GoldPure_Wt ,ISNULL(Chain_Wt ,0) Chain_Wt ,ISNULL(ChainPure_Wt,0) ChainPure_Wt ,                           
--ISNULL(Dia_Wt ,0) Dia_Wt, Isnull(DiaPcs ,0) DiaPcs ,ISNULL(DiaGram ,0) DiaGram ,ISNULL(Stone_Wt ,0) Stone_Wt ,ISNULL(StonePcs ,0) StonePcs ,                                      
--ISNULL(StoneGram ,0) StoneGram ,ISNULL(Other_Wt ,0) Other_Wt ,ISNULL(OtherPcs ,0) OtherPcs ,Entry_Type,Batch_Id                              
--FROM (                                      
--SELECT Finish_Id,CONVERT(DATE,Entry_Date) AS Entry_Date,mGold.Gold_Wt,mGold.GoldPure_Wt,mChain.Chain_Wt,mChain.ChainPure_Wt,mDia.Dia_Wt,mDia.DiaPcs,mDia.DiaGram,                                      
--mStone.Stone_Wt,mStone.StonePcs,mStone.StoneGram,mOther.Other_Wt,mOther.OtherPcs ,Entry_Type,Batch_Id                                          
--FROM dbo.Production_History_Master WITH (NOLOCK)                                      
--OUTER APPLY (                                      
--SELECT SUM(Weight) AS Gold_Wt,SUM(Pure_Wt) AS GoldPure_Wt FROM dbo.Production_History_Detail WITH (NOLOCK)                                      
--LEFT JOIN dbo.M_Metal WITH (NOLOCK) ON dbo.M_Metal.Metal_ID =  Production_History_Detail.Purity_Id                                      
--WHERE Production_History_Detail.Product_Id = dbo.Production_History_Master.Product_Id   
-- AND Production_History_Detail.Finish_Id = dbo.Production_History_Master.Finish_Id AND Material_Type = 'Metal' AND Metal_Name = 'METAL'                                      
--) AS mGold                                      
--OUTER APPLY (                                      
--SELECT SUM(Weight) AS Chain_Wt,SUM(Pure_Wt) AS ChainPure_Wt FROM dbo.Production_History_Detail WITH (NOLOCK)                                      
--LEFT JOIN dbo.M_Metal WITH (NOLOCK) ON dbo.M_Metal.Metal_ID =  Production_History_Detail.Purity_Id                                      
--WHERE Production_History_Detail.Product_Id = dbo.Production_History_Master.Product_Id   
-- AND Production_History_Detail.Finish_Id = dbo.Production_History_Master.Finish_Id AND Material_Type = 'Metal' AND Metal_Name = 'CHAIN'                                      
--) AS mChain                                      
--OUTER APPLY (                                      
--SELECT SUM(Weight) AS Dia_Wt,SUM(Pcs) AS DiaPcs,ROUND(SUM(Weight)/5,3) AS DiaGram FROM dbo.Production_History_Detail WITH (NOLOCK)                                       
--WHERE Production_History_Detail.Product_Id = dbo.Production_History_Master.Product_Id   
-- AND Production_History_Detail.Finish_Id = dbo.Production_History_Master.Finish_Id AND Material_Type = 'Diamond'                                      
--) AS mDia                                      
--OUTER APPLY (                                      
--SELECT SUM(Weight) AS Stone_Wt,SUM(Pcs) AS StonePcs,ROUND(SUM(Weight)/5,3) AS StoneGram FROM dbo.Production_History_Detail WITH (NOLOCK)                                       
--WHERE Production_History_Detail.Product_Id = dbo.Production_History_Master.Product_Id   
-- AND Production_History_Detail.Finish_Id = dbo.Production_History_Master.Finish_Id AND Material_Type = 'Stone'                                  
--) AS mStone                                                                         
--OUTER APPLY (                                      
--SELECT SUM(Weight) AS Other_Wt,SUM(Pcs) AS OtherPcs FROM dbo.Production_History_Detail WITH (NOLOCK)                                       
--WHERE Production_History_Detail.Product_Id = dbo.Production_History_Master.Product_Id   
-- AND Production_History_Detail.Finish_Id = dbo.Production_History_Master.Finish_Id AND Material_Type = 'Other'                                      
--) AS mOther                                      
--WHERE Entry_Type = 'Voucher Reverse' AND (Production_History_Master.Branch_Id=@Branch_Id OR @Branch_Id = -1) AND CONVERT(DATE,Entry_Date) BETWEEN @FromDate AND @ToDate                                                                       
--) AS m3                     
--) AS mFinalRev                      
                           
                            
--SELECT * INTO #tempCustTagRepFinal From (                            
--SELECT * FROM #tempCustTagRepair                    
                            
--UNION ALL                            
--SELECT t2.Entry_Date,t2.Finish_Id,t2.Gross_Wt,t2.Gold_Wt,t2.GoldPure_Wt,t2.Chain_Wt,t2.ChainPure_wt,t2.Dia_Wt,t2.DiaPcs,t2.DiaGram,t2.Stone_Wt,t2.stonepcs,                            
--t2.StoneGram,t2.other_wt,t2.otherpcs,t2.Batch_Id   FROM #tempCustTagRepair t1                            
--INNER JOIN #tempVoucher t2 ON t1.Finish_id=t2.Finish_id AND t1.Entry_date=t2.entry_date                             
--WHERE  t2.entry_type='Voucher Entry'                  
                         
--UNION ALL          
--SELECT t3.Entry_Date,t3.Finish_Id,t3.Gross_Wt,t3.Gold_Wt,t3.GoldPure_Wt,t3.Chain_Wt,t3.ChainPure_wt,t3.Dia_Wt,t3.DiaPcs,t3.DiaGram,t3.Stone_Wt,t3.stonepcs,                            
--t3.StoneGram,t3.other_wt,t3.otherpcs,t3.Batch_Id   FROM #tempCustTagRepair t1                            
--INNER JOIN #tempVoucherReverse t3 ON t1.Finish_id=t3.Finish_id AND t1.Entry_date=t3.entry_date                             
--WHERE t3.entry_type='Voucher Reverse'                   
                        
--) mtagfinal                            
                           
--SELECT Item_FinishGood_Master.TagNo,dbo.Item_FinishGood_Master.Finish_Id,Category_Name,Cust_Name,Cust_Code,                                                      
--Batch_No,Touch.Metal_Type AS Touch,Item_FinishGood_Master.StyleBio,dbo.Batch_Master.Total_Loss ,                                   
--CASE WHEN SUM(tp.Gross_Wt) <0 THEN 0 ELSE  SUM(tp.Gross_Wt) END  AS Gross_Wt,                        
--CASE WHEN SUM(tp.Dia_Wt) <0 THEN 0 ELSE  SUM(tp.Dia_Wt) END  Dia_Wt,                        
--CASE WHEN Sum(DiaGram)<0 then 0 ELSE  Sum(DiaGram) END  Dia_Gram,                        
--CASE WHEN SUM(StoneGram)  <0 THEN 0 ELSE SUM(StoneGram) END Stone_Gram,                        
--CASE WHEN SUM(DiaPcs)<0 THEN 0 ELSE  SUM(DiaPcs)end AS Dia_Pcs,                                                      
--CASE WHEN SUM(tp.Gold_Wt)<0 THEN 0 ELSE SUM(tp.Gold_Wt) END AS Gold_Wt,                        
--CASE WHEN SUM(tp.Chain_Wt)<0 THEN 0 ELSE  SUM(tp.Chain_Wt) END AS Chain_Wt,   
--CASE WHEN SUM(GoldPure_Wt) + SUM(ChainPure_Wt)<0 THEN 0 ELSE SUM(GoldPure_Wt) + SUM(ChainPure_Wt) END AS Pure_Wt,                                      
--CASE WHEN SUM(tp.Gold_Wt) + SUM(tp.Chain_Wt) - SUM(GoldPure_Wt) - SUM(ChainPure_Wt) <0 THEN 0 ELSE                        
--SUM(tp.Gold_Wt) + SUM(tp.Chain_Wt) - SUM(GoldPure_Wt) - SUM(ChainPure_Wt) END AS Alloy,                        
--CASE WHEN SUM(tp.Stone_Wt)<0 THEN 0 ELSE SUM(tp.Stone_Wt) END  As Stone_Wt ,       
--CASE WHEN SUM(tp.Other_Wt)<0 THEN 0 ELSE SUM(tp.Other_Wt) END As Other_Wt ,                         
                                              
--CASE WHEN dbo.Item_FinishGood_Master.Is_Approve = 1 THEN 'Approve'  WHEN dbo.Item_FinishGood_Master.Is_Issue_To_Lab = 1 THEN 'IssueToLab'                                               
--WHEN dbo.Item_FinishGood_Master.Is_item = 1 THEN 'Item'  WHEN dbo.Item_FinishGood_Master.Is_Locker = 1 THEN 'Locker'                                                                             
--WHEN dbo.Item_FinishGood_Master.Is_Marge = 1 THEN 'Merge'  WHEN dbo.Item_FinishGood_Master.Is_Repair = 1 THEN 'Repair'                                                                             
--WHEN dbo.Item_FinishGood_Master.Is_Sales = 1  AND dbo.Item_FinishGood_Master.Sold_Repair = 0  THEN 'Sale'  WHEN dbo.Item_FinishGood_Master.Is_SalesMan = 1 THEN 'Salesman Transfer'                   
--WHEN dbo.Item_FinishGood_Master.Is_Split= 1 THEN 'Split'  WHEN dbo.Item_FinishGood_Master.Status = 1 THEN 'Branch Transfer' ELSE 'STOCK' END AS [Status]                                       
--FROM #tempCustTagRepFinal AS tp                                      
--LEFT JOIN dbo.Item_FinishGood_Master WITH (NOLOCK) ON dbo.Item_FinishGood_Master.Finish_Id = tp.Finish_Id                                                                          
--LEFT JOIN dbo.Batch_Master WITH (NOLOCK) ON dbo.Batch_Master.Batch_Id = dbo.Item_FinishGood_Master.Batch_Id                                       
--LEFT JOIN dbo.M_Metal AS Touch ON Touch.Metal_ID = dbo.Item_FinishGood_Master.Metal_ID                                                                          
--LEFT JOIN dbo.M_Category ON dbo.M_Category.Category_ID = dbo.Item_FinishGood_Master.Category_Id                           
--LEFT JOIN dbo.M_Customer ON dbo.M_Customer.Cust_ID = dbo.Item_FinishGood_Master.Customer_Id                               
--WHERE Setting_Id IN (SELECT * FROM  dbo.HDSplit(@Setting_Id )) AND Item_FinishGood_Master.TagNo = CASE WHEN @TagNo <>'' THEN  @TagNo ELSE Item_FinishGood_Master.TagNo END               
--GROUP BY Item_FinishGood_Master.TagNo,dbo.Item_FinishGood_Master.Finish_Id,Category_Name,Cust_Name,Cust_Code,                                                      
--Batch_No,Touch.Metal_Type,Item_FinishGood_Master.StyleBio,dbo.Batch_Master.Total_Loss ,                                      
--CASE WHEN dbo.Item_FinishGood_Master.Is_Approve = 1 THEN 'Approve'  WHEN dbo.Item_FinishGood_Master.Is_Issue_To_Lab = 1 THEN 'IssueToLab'                                                                             
--WHEN dbo.Item_FinishGood_Master.Is_item = 1 THEN 'Item'  WHEN dbo.Item_FinishGood_Master.Is_Locker = 1 THEN 'Locker'                                                                             
--WHEN dbo.Item_FinishGood_Master.Is_Marge = 1 THEN 'Merge'  WHEN dbo.Item_FinishGood_Master.Is_Repair = 1 THEN 'Repair'                                                                             
--WHEN dbo.Item_FinishGood_Master.Is_Sales = 1  AND dbo.Item_FinishGood_Master.Sold_Repair = 0  THEN 'Sale'  WHEN dbo.Item_FinishGood_Master.Is_SalesMan = 1 THEN 'Salesman Transfer'                                                                           
   
   
--WHEN dbo.Item_FinishGood_Master.Is_Split= 1 THEN 'Split'  WHEN dbo.Item_FinishGood_Master.Status = 1 THEN 'Branch Transfer' ELSE 'STOCK' END                                      
--HAVING SUM(tp.Gross_Wt) <> 0                                                   
--ORDER BY RIGHT(TagNo,5) ASC                                                 
                                                      
----SELECT Repair_Item_FinishGood_Master.TagNo,dbo.Repair_Item_FinishGood_Master.Repair_Id,dbo.Repair_Item_FinishGood_Master.Finish_Id,Category_Name,Cust_Name,                                      
----Cust_Code,Repair_Item_FinishGood_Master.Gross_Wt,Batch_No,Touch.Metal_Type AS Touch,Repair_Item_FinishGood_Master.StyleBio,dbo.Batch_Master.Total_Loss ,                                                     
----CASE WHEN Repair_Item_FinishGood_Master.Gross_Wt > 0 THEN Repair_Item_FinishGood_Master.Gross_Wt + dbo.Batch_Master.Total_Loss ELSE 0 END AS Gross_WtAdd,                                                    
----CASE WHEN Repair_Item_FinishGood_Master.Gross_Wt < 0 THEN (Repair_Item_FinishGood_Master.Gross_Wt*-1) - dbo.Batch_Master.Total_Loss ELSE 0 END AS Gross_WtLess,                                                                  
----CASE WHEN  ISNULL(mDia.Dia_Wt,0) < 0 THEN 0 ELSE ISNULL(mDia.Dia_Wt,0) END Dia_Wt,                        
----CASE WHEN ISNULL(CONVERT(DECIMAL(18,3),mDia.DiaGram),0) <0 THEN 0 ELSE  ISNULL(CONVERT(DECIMAL(18,3),mDia.DiaGram),0) END  Dia_Gram,                        
----CASE WHEN ISNULL(mDia.DiaPcs,0) < 0  THEN 0 ELSE ISNULL(mDia.DiaPcs,0) END  AS Dia_Pcs,                                                     
----CASE WHEN ISNULL(mGold.Gold_Wt,0)<0 THEN 0  else ISNULL(mGold.Gold_Wt,0) end AS Gold_Wt,                        
----CASE WHEN ISNULL(mGold.GoldPure_Wt,0)+ISNULL(mChain.ChainPure_Wt,0)<0 THEN 0 ELSE  ISNULL(mGold.GoldPure_Wt,0)+ISNULL(mChain.ChainPure_Wt,0) END AS Pure_Wt,                        
----CASE WHEN  ISNULL(mChain.Chain_Wt,0) <0 THEN 0 ELSE ISNULL(mChain.Chain_Wt,0) end AS Chain_Wt,                                                                 
----CASE WHEN ISNULL(mGold.Gold_Wt,0) + ISNULL(mChain.Chain_Wt,0) - ISNULL(mGold.GoldPure_Wt,0) - ISNULL(mChain.ChainPure_Wt,0) < 0 THEN 0                        
----ELSE ISNULL(mGold.Gold_Wt,0) + ISNULL(mChain.Chain_Wt,0) - ISNULL(mGold.GoldPure_Wt,0) - ISNULL(mChain.ChainPure_Wt,0) END  AS Alloy,                        
                                
----CASE WHEN ISNULL(Repair_Item_FinishGood_Master.Stone_Wt,0) <0 THEN 0 ELSE ISNULL(Repair_Item_FinishGood_Master.Stone_Wt,0) END  AS  Stone_Wt,                        
                        
----Round(Repair_Item_FinishGood_Master.Stone_Wt/5,3) Stone_Gram,Repair_Item_FinishGood_Master.Other_Wt,                                                                            
----CASE WHEN ifm.Is_Approve = 1 THEN 'Approve'  WHEN ifm.Is_Issue_To_Lab = 1 THEN 'IssueToLab'                                 
----WHEN ifm.Is_item = 1 THEN 'Item'  WHEN ifm.Is_Locker = 1 THEN 'Locker'                                                                             
----WHEN ifm.Is_Marge = 1 THEN 'Merge'  WHEN ifm.Is_Repair = 1 THEN 'Repair'                                                                             
----WHEN ifm.Is_Sales = 1 AND ifm.Sold_Repair = 0 THEN 'Sale'  WHEN ifm.Is_SalesMan = 1 THEN 'Salesman Transfer'                                                                             
----WHEN ifm.Is_Split= 1 THEN 'Split'  WHEN ifm.Status = 1 THEN 'Branch Transfer' ELSE 'STOCK' END AS [Status]                                                                                                     
----FROM dbo.Production_History_Master WITH (NOLOCK)                                      
----LEFT JOIN dbo.Repair_Item_FinishGood_Master WITH (NOLOCK) ON Repair_Item_FinishGood_Master.Finish_Id = Production_History_Master.Finish_Id                                                                          
----AND dbo.Production_History_Master.Batch_Id = dbo.Repair_Item_FinishGood_Master.Batch_Id                   
----LEFT JOIN dbo.Batch_Master WITH (NOLOCK) ON dbo.Batch_Master.Batch_Id = dbo.Repair_Item_FinishGood_Master.Batch_Id       
----LEFT JOIN dbo.Order_Detail WITH (NOLOCK) ON dbo.Order_Detail.Order_Detail_Id = dbo.Batch_Master.Order_Detail_Id                                              
----LEFT JOIN dbo.Item_FinishGood_Master AS ifm ON ifm.Finish_Id = dbo.Repair_Item_FinishGood_Master.Finish_Id                                                                          
----LEFT JOIN dbo.M_Metal AS Touch ON Touch.Metal_ID = dbo.Repair_Item_FinishGood_Master.Metal_ID                                                                          
----LEFT JOIN dbo.M_Category ON dbo.M_Category.Category_ID = dbo.Repair_Item_FinishGood_Master.Category_Id                                                                          
----LEFT JOIN dbo.M_Customer ON dbo.M_Customer.Cust_ID = dbo.Repair_Item_FinishGood_Master.Customer_Id                                                                            
----OUTER APPLY (                                      
----SELECT SUM(Weight) AS Gold_Wt,SUM(Pure_Wt) AS GoldPure_Wt FROM dbo.Production_History_Detail WITH (NOLOCK)                                      
----LEFT JOIN dbo.M_Metal WITH (NOLOCK) ON dbo.M_Metal.Metal_ID =  Production_History_Detail.Purity_Id                                      
----WHERE Production_History_Detail.Product_Id = dbo.Production_History_Master.Product_Id AND Material_Type = 'Metal' AND Metal_Name = 'METAL'                                      
----) AS mGold                     
----OUTER APPLY (                                      
----SELECT SUM(Weight) AS Chain_Wt,SUM(Pure_Wt) AS ChainPure_Wt FROM dbo.Production_History_Detail WITH (NOLOCK)                                      
----LEFT JOIN dbo.M_Metal WITH (NOLOCK) ON dbo.M_Metal.Metal_ID =  Production_History_Detail.Purity_Id                                      
----WHERE Production_History_Detail.Product_Id = dbo.Production_History_Master.Product_Id AND Material_Type = 'Metal' AND Metal_Name = 'CHAIN'                                      
----) AS mChain                                    
----OUTER APPLY (                                      
----SELECT SUM(Weight) AS Dia_Wt,SUM(Pcs) AS DiaPcs,ROUND(SUM(Weight)/5,3) AS DiaGram FROM dbo.Production_History_Detail WITH (NOLOCK)                                       
----WHERE Production_History_Detail.Product_Id = dbo.Production_History_Master.Product_Id AND Material_Type = 'Diamond'                                      
----) AS mDia                                      
----OUTER APPLY (                                      
----SELECT SUM(Weight) AS Stone_Wt,SUM(Pcs) AS StonePcs,ROUND(SUM(Weight)/5,3) AS StoneGram FROM dbo.Production_History_Detail WITH (NOLOCK)                                       
----WHERE Production_History_Detail.Product_Id = dbo.Production_History_Master.Product_Id AND Material_Type = 'Stone'                                      
----) AS mStone                
----OUTER APPLY (                                      
----SELECT SUM(Weight) AS Other_Wt,SUM(Pcs) AS OtherPcs FROM dbo.Production_History_Detail WITH (NOLOCK)                                       
----WHERE Production_History_Detail.Product_Id = dbo.Production_History_Master.Product_Id AND Material_Type = 'Other'                                      
----) AS mOther                                      
----WHERE CONVERT(DATE,dbo.Production_History_Master.Entry_Date) BETWEEN @FromDate AND @ToDate AND (dbo.Production_History_Master.Branch_Id=@Branch_Id OR @Branch_Id = -1)                                                                        
----AND Entry_Type IN ('Direct Repair','Sold Repair')                                      
----GROUP BY Repair_Item_FinishGood_Master.TagNo,dbo.Repair_Item_FinishGood_Master.Repair_Id,Repair_Item_FinishGood_Master.Gross_Wt,Batch_No,                                      
----dbo.Repair_Item_FinishGood_Master.Finish_Id,Category_Name,Cust_Name,Cust_Code,Touch.Metal_Type,                                                             
----Repair_Item_FinishGood_Master.StyleBio,mDia.DiaPcs,mDia.Dia_Wt,mDia.DiaGram,         
----ISNULL(mGold.Gold_Wt,0),ISNULL(mChain.Chain_Wt,0),ISNULL(mGold.GoldPure_Wt,0), ISNULL(mChain.ChainPure_Wt,0),dbo.Batch_Master.Total_Loss ,                                                                      
----Repair_Item_FinishGood_Master.Stone_Wt,Repair_Item_FinishGood_Master.Other_Wt,                                                      
----CASE WHEN ifm.Is_Approve = 1 THEN 'Approve'  WHEN ifm.Is_Issue_To_Lab = 1 THEN 'IssueToLab'                                                                             
----WHEN ifm.Is_item = 1 THEN 'Item'  WHEN ifm.Is_Locker = 1 THEN 'Locker'                                                                             
----WHEN ifm.Is_Marge = 1 THEN 'Merge'  WHEN ifm.Is_Repair = 1 THEN 'Repair'                          
----WHEN ifm.Is_Sales = 1 AND ifm.Sold_Repair = 0 THEN 'Sale'  WHEN ifm.Is_SalesMan = 1 THEN 'Salesman Transfer'                                                                             
----WHEN ifm.Is_Split= 1 THEN 'Split'  WHEN ifm.Status = 1 THEN 'Branch Transfer' ELSE 'STOCK' END                                                       
                                                  
                                                
----- Production Material Wise Metal Detail                         
--SELECT * INTO #tempMetalProduction1 FROM (                                      
--SELECT  CONVERT(DATE,Entry_Date) Entry_Date, Finish_Id ,Purity_Id, ISNULL(G_Weight,0) G_Weight                       
--FROM (                     
--SELECT Production_History_Master.Finish_Id,CONVERT(DATE,dbo.Production_History_Master.Entry_Date) AS Entry_Date,dbo.Production_History_Detail.Purity_Id,SUM(Weight) AS G_Weight                     
--FROM dbo.Production_History_Master WITH (NOLOCK)                       
--LEFT JOIN dbo.Production_History_Detail  WITH (NOLOCK) ON dbo.Production_History_Master.Product_Id = dbo.Production_History_Detail.Product_Id AND Production_History_Detail.Finish_Id = dbo.Production_History_Master.Finish_Id          
--LEFT JOIN dbo.Item_FinishGood_Master WITH (NOLOCK) ON dbo.Production_History_Master.Finish_Id = dbo.Item_FinishGood_Master.Finish_Id                   
--WHERE Production_History_Detail.Product_Id = dbo.Production_History_Master.Product_Id AND Material_Type = 'Metal'                     
--AND  Entry_Type = 'Production' AND (Production_History_Master.Branch_Id=@Branch_Id OR @Branch_Id = -1) AND CONVERT(DATE,dbo.Production_History_Master.Entry_Date) BETWEEN @FromDate AND @ToDate         
--AND Setting_Id IN (SELECT * FROM  dbo.HDSplit(@Setting_Id )) AND Item_FinishGood_Master.TagNo = CASE WHEN @TagNo <>'' THEN  @TagNo ELSE Item_FinishGood_Master.TagNo END                      
--GROUP BY Production_History_Master.Finish_Id,CONVERT(DATE,dbo.Production_History_Master.Entry_Date) ,dbo.Production_History_Detail.Purity_Id                                     
--) AS m1          
                            
--) AS mproduction                            
                         
                                
--SELECT * INTO #tempMetalVoucher FROM (                                      
--SELECT  CONVERT(DATE,Entry_Date) Entry_Date, Finish_Id ,Purity_Id, ISNULL(G_Weight,0)*-1 G_Weight ,Entry_Type                  
--FROM (                     
--SELECT Production_History_Master.Finish_Id,CONVERT(DATE,dbo.Production_History_Master.Entry_Date) AS Entry_Date,dbo.Production_History_Detail.Purity_Id,SUM(Weight) AS G_Weight  ,Entry_Type                                       
--FROM dbo.Production_History_Master WITH (NOLOCK)                    
--LEFT JOIN dbo.Production_History_Detail  WITH (NOLOCK) ON dbo.Production_History_Master.Product_Id = dbo.Production_History_Detail.Product_Id AND Production_History_Detail.Finish_Id = dbo.Production_History_Master.Finish_Id         
--LEFT JOIN dbo.Item_FinishGood_Master WITH (NOLOCK) ON dbo.Production_History_Master.Finish_Id = dbo.Item_FinishGood_Master.Finish_Id                               
--WHERE Production_History_Detail.Product_Id = dbo.Production_History_Master.Product_Id AND Material_Type = 'Metal'                     
--AND  Entry_Type = 'Voucher Entry' AND (Production_History_Master.Branch_Id=@Branch_Id OR @Branch_Id = -1) AND CONVERT(DATE,dbo.Production_History_Master.Entry_Date) BETWEEN @FromDate AND @ToDate         
--AND Setting_Id IN (SELECT * FROM  dbo.HDSplit(@Setting_Id )) AND Item_FinishGood_Master.TagNo = CASE WHEN @TagNo <>'' THEN  @TagNo ELSE Item_FinishGood_Master.TagNo END                     
--GROUP BY Production_History_Master.Finish_Id,CONVERT(DATE,dbo.Production_History_Master.Entry_Date) ,dbo.Production_History_Detail.Purity_Id,Entry_Type                                                                        
--) AS m2                                      
                                      
--) AS mFinal                               
                            
                      
--SELECT * INTO #tempMetalProductionFinal From (                            
--SELECT DISTINCT * FROM #tempMetalProduction1                              
--UNION ALL                            
                            
--SELECT DISTINCT t2.Entry_Date,t2.Finish_Id,t2.Purity_Id,t2.G_Weight FROM #tempMetalProduction1 t1                            
--INNER JOIN #tempMetalVoucher t2 ON t1.Finish_id=t2.Finish_id AND t1.Entry_date=t2.entry_date                             
--WHERE                              
--t2.entry_type='Voucher Entry'                              
--) mmfinalll                            
                    
--SELECT Metal_Type ,                                                     
--SUM(tp.G_Weight) AS G_Weight ,  CONVERT(NUMERIC(18,3), SUM(ROUND((tp.G_Weight*Metal_Ratio),3))) AS Pure_Wt,                                      
--SUM(tp.G_Weight) -  CONVERT(NUMERIC(18,3), SUM(ROUND((tp.G_Weight*Metal_Ratio),3))) AS Alloy                         
--FROM #tempMetalProductionFinal AS tp                      
--LEFT JOIN dbo.M_Metal ON tp.Purity_Id=Metal_ID  
--GROUP BY Metal_Type  
--HAVING SUM(tp.G_Weight) <> 0                                                 
----SELECT * INTO #tempMetal FROM (                                      
----SELECT Entry_Date, Finish_Id ,Metal_Type,ISNULL(Weight,0) Weight,ISNULL(Pure_Wt,0) Pure_Wt ,ISNULL(Alloy ,0) Alloy FROM (                                      
----SELECT Production_History_Detail.Finish_Id,CONVERT(DATE,Entry_Date) AS Entry_Date,Metal_Type,SUM(Weight) Weight,SUM(Pure_Wt) Pure_Wt,SUM(Weight) - SUM(Pure_Wt) AS Alloy                                                                 
----FROM Production_History_Detail WITH (NOLOCK)                                      
----LEFT JOIN dbo.M_Metal WITH (NOLOCK) ON dbo.M_Metal.Metal_ID = Production_History_Detail.Purity_Id                                      
----LEFT JOIN dbo.Production_History_Master WITH (NOLOCK) ON dbo.Production_History_Detail.Product_Id = dbo.Production_History_Master.Product_Id                                      
----WHERE Entry_Type = 'Production' AND (Production_History_Master.Branch_Id=@Branch_Id OR @Branch_Id = -1) AND CONVERT(DATE,Entry_Date) BETWEEN @FromDate AND @ToDate                           
----AND Material_Type = 'Metal'                                      
----GROUP BY Production_History_Detail.Finish_Id,CONVERT(DATE,Entry_Date) ,Metal_Type                                   
----) AS m1                                
----UNION ALL                                      
------SELECT Entry_Date, Finish_Id,Metal_Type ,ISNULL(Weight,0)*-1 Weight,ISNULL(Pure_Wt,0)*-1 Pure_Wt ,ISNULL(Alloy ,0)*-1 Alloy FROM (                                      
------SELECT Production_History_Detail.Finish_Id,CONVERT(DATE,Entry_Date) AS Entry_Date,Metal_Type,SUM(Weight) Weight,SUM(Pure_Wt) Pure_Wt,SUM(Weight) - SUM(Pure_Wt) AS Alloy                                                                 
------FROM Production_History_Detail WITH (NOLOCK)                                      
------LEFT JOIN dbo.M_Metal WITH (NOLOCK) ON dbo.M_Metal.Metal_ID = Production_History_Detail.Purity_Id                                      
------LEFT JOIN dbo.Production_History_Master WITH (NOLOCK) ON dbo.Production_History_Detail.Product_Id = dbo.Production_History_Master.Product_Id                    
------WHERE Entry_Type = 'Voucher Entry' AND (Production_History_Master.Branch_Id=@Branch_Id OR @Branch_Id = -1) AND CONVERT(DATE,Entry_Date) BETWEEN @FromDate AND @ToDate      
------AND Material_Type = 'Metal'                                      
------GROUP BY Production_History_Detail.Finish_Id,CONVERT(DATE,Entry_Date) ,Metal_Type                                      
------) AS m2                                      
----SELECT Entry_Date, Finish_Id,Metal_Type ,ISNULL(Weight,0)*-1 Weight,ISNULL(Pure_Wt,0)*-1 Pure_Wt ,ISNULL(Alloy ,0)*-1 Alloy FROM (                                      
----SELECT Production_History_Detail.Finish_Id,CONVERT(DATE,Production_History_Master.Entry_Date) AS Entry_Date,Metal_Type,SUM(Weight) Weight,SUM(Pure_Wt) Pure_Wt,SUM(Weight) - SUM(Pure_Wt) AS Alloy                                                          
  
  
   
  
   
  
  
    
      
       
----FROM Production_History_Detail WITH (NOLOCK)                                      
----LEFT JOIN dbo.M_Metal WITH (NOLOCK) ON dbo.M_Metal.Metal_ID = Production_History_Detail.Purity_Id                           
----LEFT JOIN dbo.Production_History_Master WITH (NOLOCK) ON dbo.Production_History_Detail.Product_Id = dbo.Production_History_Master.Product_Id                                      
----LEFT JOIN (SELECT TagNo,Entry_Date,Product_Id FROM dbo.Production_History_Master                              
----WHERE Entry_Type = 'Production' AND (Production_History_Master.Branch_Id=@Branch_Id OR @Branch_Id = -1)                              
----AND CONVERT(DATE,Entry_Date) BETWEEN @FromDate AND @ToDate) AS TodayProduction                               
----ON dbo.Production_History_Master.TagNo = TodayProduction.TagNo                              
                              
----WHERE Entry_Type = 'Voucher Entry' AND (Production_History_Master.Branch_Id=@Branch_Id OR @Branch_Id = -1) AND CONVERT(DATE,Production_History_Master.Entry_Date) BETWEEN @FromDate AND @ToDate                                      
----AND Material_Type = 'Metal'        AND dbo.Production_History_Master.TagNo = TodayProduction.TagNo                                    
----GROUP BY Production_History_Detail.Finish_Id,CONVERT(DATE,Production_History_Master.Entry_Date) ,Metal_Type                                      
----) AS m2                               
----) AS mFinal              
                               
----SELECT Metal_Type,SUM(Weight) G_Weight,SUM(Pure_Wt) Pure_Wt,SUM(Alloy) Alloy FROM #tempMetal                                  
----GROUP BY Metal_Type                                
----HAVING SUM(Weight) > 0                                                 
                                                  
                                                  
----- Production Material Wise Diamond Detail                         
-- SELECT * INTO #tempDiamProduction1 FROM (                                    
--SELECT CONVERT(DATE,Entry_Date) Entry_Date, Finish_Id , Shape_Id,Purity_Id,Size_Id ,ISNULL(Dia_Wt ,0) Dia_Wt,ISNULL(Dia_Pcs,0) AS Dia_Pcs  FROM (                                    
--SELECT dbo.Production_History_Master.Finish_Id,CONVERT(DATE,dbo.Production_History_Master.Entry_Date) AS Entry_Date,mDia.Dia_Wt,mDia.Dia_Pcs,mDia.Shape_Id,mDia.Purity_Id,mDia.Size_Id                                                                  
--FROM dbo.Production_History_Master WITH (NOLOCK)           
--LEFT JOIN dbo.Item_FinishGood_Master WITH (NOLOCK) ON dbo.Production_History_Master.Finish_Id = dbo.Item_FinishGood_Master.Finish_Id                    
--OUTER APPLY (                                    
--SELECT  Production_History_Detail.Shape_Id,Production_History_Detail.Purity_Id,Production_History_Detail.Size_Id, SUM(Weight) AS Dia_Wt,SUM(Pcs) AS Dia_Pcs FROM dbo.Production_History_Detail WITH (NOLOCK)                                     
--WHERE Production_History_Detail.Product_Id = dbo.Production_History_Master.Product_Id AND Production_History_Detail.Finish_Id = dbo.Production_History_Master.Finish_Id AND Material_Type = 'Diamond'                       
--GROUP BY Production_History_Detail.Shape_Id,Production_History_Detail.Purity_Id,Production_History_Detail.Size_Id                                   
--) AS mDia                                    
                                   
--WHERE Entry_Type = 'Production' AND (Production_History_Master.Branch_Id=@Branch_Id OR @Branch_Id = -1) AND CONVERT(DATE,dbo.Production_History_Master.Entry_Date) BETWEEN @FromDate AND @ToDate        
--AND Setting_Id IN (SELECT * FROM  dbo.HDSplit(@Setting_Id )) AND Item_FinishGood_Master.TagNo = CASE WHEN @TagNo <>'' THEN  @TagNo ELSE Item_FinishGood_Master.TagNo END                                               
--) AS m1                             
                          
--) AS mproduction                          
                                  
--SELECT * INTO #tempDiamVoucher FROM (                                    
--SELECT CONVERT(DATE,Entry_Date) Entry_Date, Finish_Id ,Shape_Id,Purity_Id,Size_Id , ISNULL(Dia_Wt ,0)*-1 Dia_Wt,ISNULL(Dia_Pcs,0)*-1 Dia_Pcs, Entry_Type                            
--FROM (                                    
--SELECT dbo.Production_History_Master.Finish_Id,CONVERT(DATE,dbo.Production_History_Master.Entry_Date) AS Entry_Date,mDia.Dia_Wt,mDia.Dia_Pcs,mDia.Shape_Id,mDia.Purity_Id,mDia.Size_Id ,Entry_Type                                                             
    
--FROM dbo.Production_History_Master WITH (NOLOCK)                        
--LEFT JOIN dbo.Item_FinishGood_Master WITH (NOLOCK) ON dbo.Production_History_Master.Finish_Id = dbo.Item_FinishGood_Master.Finish_Id                             
--OUTER APPLY (                                    
--SELECT Production_History_Detail.Shape_Id,Production_History_Detail.Purity_Id,Production_History_Detail.Size_Id,SUM(Weight) AS Dia_Wt,SUM(Pcs) AS Dia_Pcs FROM dbo.Production_History_Detail WITH (NOLOCK)                                     
--WHERE Production_History_Detail.Product_Id = dbo.Production_History_Master.Product_Id AND Production_History_Detail.Finish_Id = dbo.Production_History_Master.Finish_Id AND Material_Type = 'Diamond'                       
--GROUP BY Production_History_Detail.Shape_Id,Production_History_Detail.Purity_Id,Production_History_Detail.Size_Id                                   
--) AS mDia                                    
--WHERE Entry_Type = 'Voucher Entry' AND (Production_History_Master.Branch_Id=@Branch_Id OR @Branch_Id = -1) AND CONVERT(DATE,dbo.Production_History_Master.Entry_Date) BETWEEN @FromDate AND @ToDate         
--AND Setting_Id IN (SELECT * FROM  dbo.HDSplit(@Setting_Id )) AND Item_FinishGood_Master.TagNo = CASE WHEN @TagNo <>'' THEN  @TagNo ELSE Item_FinishGood_Master.TagNo END  
--) AS m2                         
                                    
--) AS mFinal                             
                         
                        
--SELECT * INTO #tempDiamond From (                          
--SELECT DISTINCT * FROM #tempDiamProduction1                            
--UNION ALL                          
--SELECT DISTINCT  t2.Entry_Date,t2.Finish_Id,t2.Shape_Id,t2.Purity_Id,t2.Size_Id,t2.Dia_Wt,t2.Dia_Pcs  FROM #tempDiamProduction1 t1                          
--INNER JOIN #tempDiamVoucher t2 ON t1.Finish_id=t2.Finish_id AND t1.Entry_date=t2.entry_date     
--WHERE                            
--t2.entry_type='Voucher Entry'                            
--) mmfinalll                          
                      
                      
                                 
--SELECT Shape_Name,Purity_Name,Size_Name , SUM(tp.Dia_Wt) Cts FROM #tempDiamond AS tp                                    
--LEFT JOIN dbo.M_Diamond WITH (NOLOCK) ON dbo.M_Diamond.Diamond_ID = tp.Shape_Id                                                                        
--LEFT JOIN dbo.M_Purity WITH (NOLOCK) ON dbo.M_Purity.Purity_ID = tp.Purity_Id                                                                    
--LEFT JOIN dbo.M_Size WITH (NOLOCK) ON dbo.M_Size.Size_ID = tp.Size_Id   
--GROUP BY  Shape_Name,Purity_Name,Size_Name                                                          
--HAVING SUM(tp.Dia_Wt) <> 0                                                 
----SELECT * INTO #tempDiamond FROM (                                      
----SELECT Entry_Date, Finish_Id ,Shape_Name,Purity_Name,Size_Name,ISNULL(Weight,0) Weight FROM (                                   
----SELECT Production_History_Detail.Finish_Id,CONVERT(DATE,Entry_Date) AS Entry_Date,Shape_Name,Purity_Name,Size_Name,SUM(Weight) Weight                                      
----FROM Production_History_Detail WITH (NOLOCK)                                      
----LEFT JOIN dbo.M_Diamond WITH (NOLOCK) ON dbo.M_Diamond.Diamond_ID = dbo.Production_History_Detail.Shape_Id                                                                        
----LEFT JOIN dbo.M_Purity WITH (NOLOCK) ON dbo.M_Purity.Purity_ID = dbo.Production_History_Detail.Purity_Id                                                                    
----LEFT JOIN dbo.M_Size WITH (NOLOCK) ON dbo.M_Size.Size_ID = dbo.Production_History_Detail.Size_Id                                                
----LEFT JOIN dbo.Production_History_Master WITH (NOLOCK) ON dbo.Production_History_Detail.Product_Id = dbo.Production_History_Master.Product_Id                                      
----WHERE Entry_Type = 'Production' AND (Production_History_Master.Branch_Id=@Branch_Id OR @Branch_Id = -1) AND CONVERT(DATE,Entry_Date) BETWEEN @FromDate AND @ToDate                                      
----AND Material_Type = 'Diamond'                 
----GROUP BY Production_History_Detail.Finish_Id,CONVERT(DATE,Entry_Date) ,Shape_Name,Purity_Name,Size_Name                                      
----) AS m1                                       
----UNION ALL                                      
----SELECT Entry_Date, Finish_Id,Shape_Name,Purity_Name,Size_Name,ISNULL(Weight,0)*-1 Weight FROM (                                      
----SELECT Production_History_Detail.Finish_Id,CONVERT(DATE,Entry_Date) AS Entry_Date,Shape_Name,Purity_Name,Size_Name,SUM(Weight) Weight                                                                 
----FROM Production_History_Detail WITH (NOLOCK)                                      
----LEFT JOIN dbo.M_Diamond WITH (NOLOCK) ON dbo.M_Diamond.Diamond_ID = dbo.Production_History_Detail.Shape_Id                                                                        
----LEFT JOIN dbo.M_Purity WITH (NOLOCK) ON dbo.M_Purity.Purity_ID = dbo.Production_History_Detail.Purity_Id                                                                      
----LEFT JOIN dbo.M_Size WITH (NOLOCK) ON dbo.M_Size.Size_ID = dbo.Production_History_Detail.Size_Id                                         
----LEFT JOIN dbo.Production_History_Master WITH (NOLOCK) ON dbo.Production_History_Detail.Product_Id = dbo.Production_History_Master.Product_Id                                    
----WHERE Entry_Type = 'Voucher Entry' AND (Production_History_Master.Branch_Id=@Branch_Id OR @Branch_Id = -1) AND CONVERT(DATE,Entry_Date) BETWEEN @FromDate AND @ToDate                                  
----AND Material_Type = 'Diamond'                                      
----GROUP BY Production_History_Detail.Finish_Id,CONVERT(DATE,Entry_Date) ,Shape_Name,Purity_Name,Size_Name                            
----) AS m2                                      
----) AS mFinal                                      
                                      
----SELECT Shape_Name,Purity_Name,Size_Name,SUM(Weight) Cts FROM #tempDiamond                                      
----GROUP BY Shape_Name,Purity_Name,Size_Name                                                  
                                                  
                                                  
----- Production Material Wise Other Detail                           
--SELECT 'Other' MType,SUM(tp.Other_Wt) As Weight                         
--FROM #tempProduction AS tp       
--LEFT JOIN dbo.Item_FinishGood_Master WITH (NOLOCK) ON dbo.Item_FinishGood_Master.Finish_Id = tp.Finish_Id      
--WHERE Setting_Id IN (SELECT * FROM  dbo.HDSplit(@Setting_Id )) AND Item_FinishGood_Master.TagNo = CASE WHEN @TagNo <>'' THEN  @TagNo ELSE Item_FinishGood_Master.TagNo END      
--HAVING   SUM(tp.Other_Wt) <> 0                    
--UNION ALL                        
--SELECT 'Stone' MType,SUM(tp.Stone_Wt) As Weight                         
--FROM #tempProduction AS tp      
--LEFT JOIN dbo.Item_FinishGood_Master WITH (NOLOCK) ON dbo.Item_FinishGood_Master.Finish_Id = tp.Finish_Id                                                                          
--WHERE Setting_Id IN (SELECT * FROM  dbo.HDSplit(@Setting_Id )) AND Item_FinishGood_Master.TagNo = CASE WHEN @TagNo <>'' THEN  @TagNo ELSE Item_FinishGood_Master.TagNo END      
-- HAVING   SUM(tp.Stone_Wt) <> 0                                               
----SELECT * INTO #tempOther FROM (                                      
----SELECT Entry_Date, Finish_Id ,Material_Type,ISNULL(Weight,0) Weight FROM (                                      
----SELECT Production_History_Detail.Finish_Id,CONVERT(DATE,Entry_Date) AS Entry_Date,Material_Type,SUM(Weight) Weight                                              
----FROM Production_History_Detail WITH (NOLOCK)                                      
----LEFT JOIN dbo.Production_History_Master WITH (NOLOCK) ON dbo.Production_History_Detail.Product_Id = dbo.Production_History_Master.Product_Id                                      
----WHERE Entry_Type = 'Production' AND (Production_History_Master.Branch_Id=@Branch_Id OR @Branch_Id = -1) AND CONVERT(DATE,Entry_Date) BETWEEN @FromDate AND @ToDate                                      
----AND Material_Type IN ('Stone','Other')                                      
----GROUP BY Production_History_Detail.Finish_Id,CONVERT(DATE,Entry_Date) ,Material_Type                                    
----) AS m1                                       
----UNION ALL                                      
----SELECT Entry_Date, Finish_Id,Material_Type,ISNULL(Weight,0)*-1 Weight FROM (                                      
----SELECT Production_History_Detail.Finish_Id,CONVERT(DATE,Entry_Date) AS Entry_Date,Material_Type,SUM(Weight) Weight                                                                 
----FROM Production_History_Detail WITH (NOLOCK)                                      
----LEFT JOIN dbo.Production_History_Master WITH (NOLOCK) ON dbo.Production_History_Detail.Product_Id = dbo.Production_History_Master.Product_Id                                      
----WHERE Entry_Type = 'Voucher Entry' AND (Production_History_Master.Branch_Id=@Branch_Id OR @Branch_Id = -1) AND CONVERT(DATE,Entry_Date) BETWEEN @FromDate AND @ToDate                                      
----AND Material_Type IN ('Stone','Other')                                      
----GROUP BY Production_History_Detail.Finish_Id,CONVERT(DATE,Entry_Date) ,Material_Type                  
----) AS m2                                      
----) AS mFinal                                      
                                      
----SELECT Material_Type AS MType,SUM(Weight) Weight FROM #tempOther                          --GROUP BY Material_Type                                                           
                                                  
                                                  
----- Tag Repair Material Wise Metal Detail                     
--SELECT * INTO #tempMetalTagVoucherReverse FROM (                                      
--SELECT  CONVERT(DATE,Entry_Date) Entry_Date, Finish_Id ,Purity_Id, ISNULL(G_Weight,0) G_Weight                       
--FROM (                     
--SELECT Production_History_Master.Finish_Id,CONVERT(DATE,dbo.Production_History_Master.Entry_Date) AS Entry_Date,dbo.Production_History_Detail.Purity_Id,SUM(Weight) AS G_Weight                     
--FROM dbo.Production_History_Master WITH (NOLOCK)                       
--LEFT JOIN dbo.Production_History_Detail  WITH (NOLOCK) ON dbo.Production_History_Master.Product_Id = dbo.Production_History_Detail.Product_Id AND Production_History_Detail.Finish_Id = dbo.Production_History_Master.Finish_Id              
--LEFT JOIN dbo.Item_FinishGood_Master WITH (NOLOCK) ON dbo.Production_History_Detail.Finish_Id = dbo.Item_FinishGood_Master.Finish_Id               
--WHERE Production_History_Detail.Product_Id = dbo.Production_History_Master.Product_Id AND Material_Type = 'Metal'                     
--AND  Entry_Type = 'Voucher Reverse' AND (Production_History_Master.Branch_Id=@Branch_Id OR @Branch_Id = -1) AND CONVERT(DATE,dbo.Production_History_Master.Entry_Date) BETWEEN @FromDate AND @ToDate        
--AND Setting_Id IN (SELECT * FROM  dbo.HDSplit(@Setting_Id )) AND Item_FinishGood_Master.TagNo = CASE WHEN @TagNo <>'' THEN  @TagNo ELSE Item_FinishGood_Master.TagNo END                   
--GROUP BY Production_History_Master.Finish_Id,CONVERT(DATE,dbo.Production_History_Master.Entry_Date) ,dbo.Production_History_Detail.Purity_Id                                     
--) AS m2                                      
--) AS mtagVoucherReverse  
  
                                               
--SELECT * INTO #tempMetalTagRepair FROM (                                      
--SELECT  CONVERT(DATE,Entry_Date) Entry_Date, Finish_Id ,Purity_Id, ISNULL(G_Weight,0) G_Weight                       
--FROM (                     
--SELECT Production_History_Master.Finish_Id,CONVERT(DATE,dbo.Production_History_Master.Entry_Date) AS Entry_Date,dbo.Production_History_Detail.Purity_Id,SUM(Weight) AS G_Weight                     
--FROM dbo.Production_History_Master WITH (NOLOCK)                       
--LEFT JOIN dbo.Production_History_Detail  WITH (NOLOCK) ON dbo.Production_History_Master.Product_Id = dbo.Production_History_Detail.Product_Id  AND Production_History_Detail.Finish_Id = dbo.Production_History_Master.Finish_Id             
--LEFT JOIN dbo.Item_FinishGood_Master WITH (NOLOCK) ON dbo.Production_History_Detail.Finish_Id = dbo.Item_FinishGood_Master.Finish_Id               
--WHERE Production_History_Detail.Product_Id = dbo.Production_History_Master.Product_Id AND Material_Type = 'Metal'                     
--AND  Entry_Type = 'Repair' AND (Production_History_Master.Branch_Id=@Branch_Id OR @Branch_Id = -1) AND CONVERT(DATE,dbo.Production_History_Master.Entry_Date) BETWEEN @FromDate AND @ToDate        
--AND Setting_Id IN (SELECT * FROM  dbo.HDSplit(@Setting_Id )) AND Item_FinishGood_Master.TagNo = CASE WHEN @TagNo <>'' THEN  @TagNo ELSE Item_FinishGood_Master.TagNo END                   
--GROUP BY Production_History_Master.Finish_Id,CONVERT(DATE,dbo.Production_History_Master.Entry_Date) ,dbo.Production_History_Detail.Purity_Id                                     
--) AS m2                                      
--) AS mtagrepair                                                      
                    
--SELECT * INTO #tempMetalTagRepFinal From (  
--SELECT DISTINCT * FROM #tempMetalTagVoucherReverse  
--UNION ALL                            
--SELECT DISTINCT * FROM #tempMetalTagRepair                              
--UNION ALL                            
--SELECT DISTINCT t1.Entry_Date,t1.Finish_Id,t1.Purity_Id,t1.G_Weight FROM #tempMetalVoucher t1  
--INNER JOIN #tempMetalTagRepair t2 ON t1.Finish_id=t2.Finish_id AND t1.Entry_date=t2.entry_date  
--INNER JOIN #tempMetalTagVoucherReverse t3 ON t1.Finish_id=t3.Finish_id AND t1.Entry_date=t3.entry_date  
--WHERE t1.entry_type='Voucher Entry'  
--) mtagfinal  
                            
-- SELECT Metal_Type ,  SUM(tp.G_Weight) AS G_Weight , CONVERT(NUMERIC(18,3),(SUM(tp.G_Weight*Metal_Ratio))) AS Pure_Wt,                                      
--SUM(tp.G_Weight) - CONVERT(NUMERIC(18,3),(SUM(tp.G_Weight*Metal_Ratio))) AS Alloy                         
--FROM #tempMetalTagRepFinal AS tp                      
--LEFT JOIN dbo.M_Metal ON tp.Purity_Id=Metal_ID       
--GROUP BY Metal_Type                         
--HAVING SUM(tp.G_Weight) <> 0                        
             
----SELECT Metal_Type,SUM(Weight) G_Weight,SUM(Pure_Wt) Pure_Wt,SUM(Weight) - SUM(Pure_Wt) AS Alloy FROM dbo.Production_History_Detail WITH (NOLOCK)                            
----LEFT JOIN dbo.M_Metal WITH (NOLOCK) ON dbo.M_Metal.Metal_ID = Production_History_Detail.Purity_Id                                      
----LEFT JOIN dbo.Production_History_Master WITH (NOLOCK) ON dbo.Production_History_Detail.Product_Id = dbo.Production_History_Master.Product_Id              
----WHERE Entry_Type = 'Repair' AND (Production_History_Master.Branch_Id=@Branch_Id OR @Branch_Id = -1) AND CONVERT(DATE,Entry_Date) BETWEEN @FromDate AND @ToDate                                       
----AND Material_Type = 'Metal'                                      
----GROUP BY Metal_Type                                      
----HAVING SUM(Weight) > 0                                 
                                                 
                                                  
----- Tag Repair Material Wise Diamond Detail                      
                    
--SELECT * INTO #tempDiamTagRepair FROM (                                    
--SELECT CONVERT(DATE,Entry_Date) Entry_Date, Finish_Id , Shape_Id,Purity_Id,Size_Id ,ISNULL(Dia_Wt ,0) Dia_Wt   FROM (                                    
--SELECT dbo.Production_History_Master.Finish_Id,CONVERT(DATE,dbo.Production_History_Master.Entry_Date) AS Entry_Date,mDia.Dia_Wt,mDia.Shape_Id,mDia.Purity_Id,mDia.Size_Id                                                                  
--FROM dbo.Production_History_Master WITH (NOLOCK)           
--LEFT JOIN dbo.Item_FinishGood_Master WITH (NOLOCK) ON dbo.Production_History_Master.Finish_Id = dbo.Item_FinishGood_Master.Finish_Id                    
--OUTER APPLY (                                    
--SELECT  Production_History_Detail.Shape_Id,Production_History_Detail.Purity_Id,Production_History_Detail.Size_Id, SUM(Weight) AS Dia_Wt FROM dbo.Production_History_Detail WITH (NOLOCK)                                     
--WHERE Production_History_Detail.Product_Id = dbo.Production_History_Master.Product_Id AND Production_History_Detail.Finish_Id = dbo.Production_History_Master.Finish_Id AND Material_Type = 'Diamond'                       
--GROUP BY Production_History_Detail.Shape_Id,Production_History_Detail.Purity_Id,Production_History_Detail.Size_Id                              
--) AS mDia                                    
--WHERE Entry_Type = 'Repair' AND (Production_History_Master.Branch_Id=@Branch_Id OR @Branch_Id = -1) AND CONVERT(DATE,dbo.Production_History_Master.Entry_Date) BETWEEN @FromDate AND @ToDate        
--AND Setting_Id IN (SELECT * FROM  dbo.HDSplit(@Setting_Id )) AND Item_FinishGood_Master.TagNo = CASE WHEN @TagNo <>'' THEN  @TagNo ELSE Item_FinishGood_Master.TagNo END  
--) AS m1       
                          
--) AS mproduction            
                                  
--SELECT * INTO #tempDiamTagRepairVoucher FROM (                                    
--SELECT CONVERT(DATE,Entry_Date) Entry_Date, Finish_Id ,Shape_Id,Purity_Id,Size_Id , ISNULL(Dia_Wt ,0)*-1 Dia_Wt, Entry_Type                            
--FROM (                                    
--SELECT dbo.Production_History_Master.Finish_Id,CONVERT(DATE,dbo.Production_History_Master.Entry_Date) AS Entry_Date,mDia.Dia_Wt,mDia.Shape_Id,mDia.Purity_Id,mDia.Size_Id ,Entry_Type                                                                 
--FROM dbo.Production_History_Master WITH (NOLOCK)                                   
--LEFT JOIN dbo.Item_FinishGood_Master WITH (NOLOCK) ON dbo.Production_History_Master.Finish_Id = dbo.Item_FinishGood_Master.Finish_Id                                        
--OUTER APPLY (                                    
--SELECT Production_History_Detail.Shape_Id,Production_History_Detail.Purity_Id,Production_History_Detail.Size_Id,SUM(Weight) AS Dia_Wt FROM dbo.Production_History_Detail WITH (NOLOCK)                                     
--WHERE Production_History_Detail.Product_Id = dbo.Production_History_Master.Product_Id AND Production_History_Detail.Finish_Id = dbo.Production_History_Master.Finish_Id AND Material_Type = 'Diamond'                       
--GROUP BY Production_History_Detail.Shape_Id,Production_History_Detail.Purity_Id,Production_History_Detail.Size_Id                                   ) AS mDia                                    
                               
--WHERE Entry_Type = 'Voucher Entry' AND (Production_History_Master.Branch_Id=@Branch_Id OR @Branch_Id = -1) AND CONVERT(DATE,dbo.Production_History_Master.Entry_Date) BETWEEN @FromDate AND @ToDate            
--AND Setting_Id IN (SELECT * FROM  dbo.HDSplit(@Setting_Id )) AND Item_FinishGood_Master.TagNo = CASE WHEN @TagNo <>'' THEN  @TagNo ELSE Item_FinishGood_Master.TagNo END                                                                     
--) AS m2                                    
                                    
--) AS mFinal                             
                         
                          
--SELECT * INTO #tempTagRepairDiamond From (                          
--SELECT DISTINCT  * FROM #tempDiamTagRepair                            
--UNION ALL                          
--SELECT DISTINCT  t2.Entry_Date,t2.Finish_Id,t2.Shape_Id,t2.Purity_Id,t2.Size_Id,t2.Dia_Wt  FROM #tempDiamTagRepair t1                          
--INNER JOIN #tempDiamTagRepairVoucher t2 ON t1.Finish_id=t2.Finish_id AND t1.Entry_date=t2.entry_date                           
--WHERE                            
--t2.entry_type='Voucher Entry'                            
--) mmfinalll                          
                      
                      
                                 
--SELECT Shape_Name,Purity_Name,Size_Name , SUM(tp.Dia_Wt) Cts FROM #tempTagRepairDiamond AS tp                                    
--LEFT JOIN dbo.M_Diamond WITH (NOLOCK) ON dbo.M_Diamond.Diamond_ID = tp.Shape_Id                                   
--LEFT JOIN dbo.M_Purity WITH (NOLOCK) ON dbo.M_Purity.Purity_ID = tp.Purity_Id                                                                  
--LEFT JOIN dbo.M_Size WITH (NOLOCK) ON dbo.M_Size.Size_ID = tp.Size_Id                        
--GROUP BY  Shape_Name,Purity_Name,Size_Name                                                          
--HAVING SUM(tp.Dia_Wt) <> 0                      
                    
----SELECT Shape_Name,Purity_Name,Size_Name,SUM(Weight) Cts FROM dbo.Production_History_Detail WITH (NOLOCK)                                      
----LEFT JOIN dbo.M_Diamond WITH (NOLOCK) ON dbo.M_Diamond.Diamond_ID = dbo.Production_History_Detail.Shape_Id                                                                        
----LEFT JOIN dbo.M_Purity WITH (NOLOCK) ON dbo.M_Purity.Purity_ID = dbo.Production_History_Detail.Purity_Id                                                                        
----LEFT JOIN dbo.M_Size WITH (NOLOCK) ON dbo.M_Size.Size_ID = dbo.Production_History_Detail.Size_Id                                            
----LEFT JOIN dbo.Production_History_Master WITH (NOLOCK) ON dbo.Production_History_Detail.Product_Id = dbo.Production_History_Master.Product_Id                                      
----WHERE Entry_Type = 'Repair' AND (Production_History_Master.Branch_Id=@Branch_Id OR @Branch_Id = -1) AND CONVERT(DATE,Entry_Date) BETWEEN @FromDate AND @ToDate                                       
----AND Material_Type = 'Diamond'                                      
----GROUP BY Shape_Name,Purity_Name,Size_Name                 
----HAVING SUM(Weight) > 0                                                
                                                
                                                  
----- Tag Repair Material Wise Other Detail                     
--SELECT 'Other' MType,SUM(tp.Other_Wt) As Weight                         
--FROM #tempTagRepFinal AS tp HAVING   SUM(tp.Other_Wt) <> 0                    
--UNION ALL                        
--SELECT 'Stone' MType,SUM(tp.Stone_Wt) As Weight                         
--FROM #tempTagRepFinal AS tp HAVING   SUM(tp.Stone_Wt) <> 0                  
----SELECT Material_Type AS  MType,SUM(Weight) Weight FROM dbo.Production_History_Detail WITH (NOLOCK)                                      
----LEFT JOIN dbo.Production_History_Master WITH (NOLOCK) ON dbo.Production_History_Detail.Product_Id = dbo.Production_History_Master.Product_Id    
----WHERE Entry_Type = 'Repair' AND (Production_History_Master.Branch_Id=@Branch_Id OR @Branch_Id = -1) AND CONVERT(DATE,Entry_Date) BETWEEN @FromDate AND @ToDate                                       
----AND Material_Type IN ( 'Stone','Other' )                                      
----GROUP BY Material_Type                                       
----HAVING SUM(Weight) > 0                                                 
                                                  
                                                
----- Customer Tag Repair Material Wise Metal Detail     
--SELECT Metal_Type ,SUM(tp.G_Weight) AS G_Weight , CONVERT(NUMERIC(18,3),(SUM(tp.G_Weight*Metal_Ratio))) AS Pure_Wt,                                      
--SUM(tp.G_Weight) - CONVERT(NUMERIC(18,3),(SUM(tp.G_Weight*Metal_Ratio))) AS Alloy  FROM (  
--SELECT CASE WHEN Material_Type='Metal' THEN dbo.Production_History_Detail.Purity_Id ELSE 0 END AS Purity_Id,  
--(ISNULL(CASE WHEN Material_Type='Metal' THEN SUM(CASE WHEN ISNULL(Weight,0)<0 THEN 0 ELSE ISNULL(Weight,0) END) ELSE 0 END,0) +   
--ISNULL(CASE WHEN Material_Type='Diamond' THEN ROUND(SUM(Weight)/5,3) ELSE 0 END ,0) +   
--ISNULL(CASE WHEN Material_Type='Stone' THEN ROUND(SUM(Weight)/5,3) ELSE 0 END ,0) +   
--ISNULL(CASE WHEN Material_Type='Other' THEN SUM(CASE WHEN ISNULL(Weight,0)<0 THEN 0 ELSE ISNULL(Weight,0) END) ELSE 0 END ,0))*-1 AS Gross_Wt,  
--CASE WHEN Material_Type='Metal' THEN SUM(CASE WHEN ISNULL(Weight,0)<0 THEN 0 ELSE ISNULL(Weight,0) END) ELSE 0 END AS G_Weight,  
--CASE WHEN Material_Type='Diamond' THEN ROUND(SUM(Weight)/5,3) ELSE 0 END AS DiaGram,  
--CASE WHEN Material_Type='Stone' THEN ROUND(SUM(Weight)/5,3) ELSE 0 END AS StoneGram,  
--CASE WHEN Material_Type='Other' THEN SUM(CASE WHEN ISNULL(Weight,0)<0 THEN 0 ELSE ISNULL(Weight,0) END) ELSE 0 END  AS Other_Wt  
--FROM dbo.Production_History_Master WITH (NOLOCK)   
--LEFT JOIN dbo.Item_FinishGood_Master WITH (NOLOCK) ON  dbo.Production_History_Master.Finish_Id = dbo.Item_FinishGood_Master.Finish_Id  
--LEFT JOIN Production_History_Detail WITH (NOLOCK) ON Production_History_Detail.Product_Id = dbo.Production_History_Master.Product_Id AND Production_History_Detail.Finish_Id = dbo.Production_History_Master.Finish_Id   
--WHERE Entry_Type IN ('Direct Repair','Sold Repair') AND (Production_History_Master.Branch_Id=@Branch_Id OR @Branch_Id = -1) AND CONVERT(DATE,dbo.Production_History_Master.Entry_Date) BETWEEN @FromDate AND @ToDate  
--AND Setting_Id IN (SELECT * FROM  dbo.HDSplit(@Setting_Id )) AND Item_FinishGood_Master.TagNo = CASE WHEN @TagNo <>'' THEN  @TagNo ELSE Item_FinishGood_Master.TagNo END    
--GROUP BY CASE WHEN Material_Type='Metal' THEN dbo.Production_History_Detail.Purity_Id ELSE 0 END,Material_Type  
--UNION ALL  
--SELECT  CASE WHEN Material_Type='Metal' THEN dbo.Production_History_Detail.Purity_Id ELSE 0 END AS Purity_Id,  
--(ISNULL(CASE WHEN Material_Type='Metal' THEN SUM(ISNULL(Weight,0)) ELSE 0 END,0) +   
--ISNULL(CASE WHEN Material_Type='Diamond' THEN ROUND(SUM(Weight)/5,3) ELSE 0 END ,0) +   
--ISNULL(CASE WHEN Material_Type='Stone' THEN ROUND(SUM(Weight)/5,3) ELSE 0 END ,0) +   
--ISNULL(CASE WHEN Material_Type='Other' THEN SUM(ISNULL(Weight,0)) ELSE 0 END ,0))*-1 AS Gross_Wt,   
--CASE WHEN Material_Type='Metal' THEN SUM(ISNULL(Weight,0)) ELSE 0 END*-1 AS G_Weight,  
--CASE WHEN Material_Type='Diamond' THEN ROUND(SUM(Weight)/5,3) ELSE 0 END*-1 AS DiaGram,  
--CASE WHEN Material_Type='Stone' THEN ROUND(SUM(Weight)/5,3) ELSE 0 END*-1 AS StoneGram,  
--CASE WHEN Material_Type='Other' THEN SUM(ISNULL(Weight,0)) ELSE 0 END*-1  AS Other_Wt  
--FROM dbo.Production_History_Master WITH (NOLOCK)    
--LEFT JOIN dbo.Item_FinishGood_Master WITH (NOLOCK) ON  dbo.Production_History_Master.Finish_Id = dbo.Item_FinishGood_Master.Finish_Id  
--INNER JOIN dbo.Production_History_Master AS Repair WITH (NOLOCK)  ON Repair.Entry_Type IN ('Direct Repair','Sold Repair') AND dbo.Production_History_Master.Finish_Id = Repair.Finish_Id   
--AND CONVERT(DATE, dbo.Production_History_Master.Entry_Date) = CONVERT(DATE,Repair.Entry_Date)  
--LEFT JOIN Production_History_Detail WITH (NOLOCK) ON Production_History_Detail.Product_Id = dbo.Production_History_Master.Product_Id AND Production_History_Detail.Finish_Id = dbo.Production_History_Master.Finish_Id AND Material_Type = 'Metal'    
--WHERE Production_History_Master.Entry_Type IN ('Voucher Entry') AND (Production_History_Master.Branch_Id=@Branch_Id OR @Branch_Id = -1) AND CONVERT(DATE,dbo.Production_History_Master.Entry_Date) BETWEEN @FromDate AND @ToDate   
--AND Setting_Id IN (SELECT * FROM  dbo.HDSplit(@Setting_Id )) AND Item_FinishGood_Master.TagNo = CASE WHEN @TagNo <>'' THEN  @TagNo ELSE Item_FinishGood_Master.TagNo END  
--GROUP BY CASE WHEN Material_Type='Metal' THEN dbo.Production_History_Detail.Purity_Id ELSE 0 END,Material_Type  
--UNION ALL  
--SELECT CASE WHEN Material_Type='Metal' THEN dbo.Production_History_Detail.Purity_Id ELSE 0 END AS Purity_Id,  
--(ISNULL(CASE WHEN Material_Type='Metal' THEN SUM(ISNULL(Weight,0)) ELSE 0 END,0) +   
--ISNULL(CASE WHEN Material_Type='Diamond' THEN ROUND(SUM(Weight)/5,3) ELSE 0 END ,0) +   
--ISNULL(CASE WHEN Material_Type='Stone' THEN ROUND(SUM(Weight)/5,3) ELSE 0 END ,0) +   
--ISNULL(CASE WHEN Material_Type='Other' THEN SUM(ISNULL(Weight,0)) ELSE 0 END ,0)) AS Gross_Wt,   
--CASE WHEN Material_Type='Metal' THEN SUM(ISNULL(Weight,0)) ELSE 0 END AS G_Weight,  
--CASE WHEN Material_Type='Diamond' THEN ROUND(SUM(Weight)/5,3) ELSE 0 END AS DiaGram,  
--CASE WHEN Material_Type='Stone' THEN ROUND(SUM(Weight)/5,3) ELSE 0 END AS StoneGram,  
--CASE WHEN Material_Type='Other' THEN SUM(ISNULL(Weight,0)) ELSE 0 END  AS Other_Wt  
--FROM dbo.Production_History_Master WITH (NOLOCK)    
--LEFT JOIN dbo.Item_FinishGood_Master WITH (NOLOCK) ON  dbo.Production_History_Master.Finish_Id = dbo.Item_FinishGood_Master.Finish_Id  
--INNER JOIN dbo.Production_History_Master AS Repair WITH (NOLOCK)  ON Repair.Entry_Type IN ('Direct Repair','Sold Repair') AND dbo.Production_History_Master.Finish_Id = Repair.Finish_Id  
--AND CONVERT(DATE,dbo.Production_History_Master.Entry_Date) = CONVERT(DATE,Repair.Entry_Date)  
--LEFT JOIN Production_History_Detail WITH (NOLOCK) ON Production_History_Detail.Product_Id = dbo.Production_History_Master.Product_Id AND Production_History_Detail.Finish_Id = dbo.Production_History_Master.Finish_Id AND Material_Type = 'Metal'    
--WHERE dbo.Production_History_Master.Entry_Type IN ('Voucher Reverse') AND (Production_History_Master.Branch_Id=@Branch_Id OR @Branch_Id = -1) AND CONVERT(DATE,dbo.Production_History_Master.Entry_Date) BETWEEN @FromDate AND @ToDate   
--AND Setting_Id IN (SELECT * FROM  dbo.HDSplit(@Setting_Id )) AND Item_FinishGood_Master.TagNo = CASE WHEN @TagNo <>'' THEN  @TagNo ELSE Item_FinishGood_Master.TagNo END  
--GROUP BY CASE WHEN Material_Type='Metal' THEN dbo.Production_History_Detail.Purity_Id ELSE 0 END,Material_Type   
--) AS tp  
--LEFT JOIN dbo.M_Metal ON tp.Purity_Id=Metal_ID                    
--GROUP BY Metal_Type                         
--HAVING SUM(tp.Gross_Wt) <> 0 AND SUM(tp.G_Weight) <> 0                                               
----SELECT Metal_Type,SUM(Weight) G_Weight,SUM(Pure_Wt) Pure_Wt,SUM(Weight) - SUM(Pure_Wt) AS Alloy FROM dbo.Production_History_Detail WITH (NOLOCK)                                      
----LEFT JOIN dbo.M_Metal WITH (NOLOCK) ON dbo.M_Metal.Metal_ID = Production_History_Detail.Purity_Id                                      
----LEFT JOIN dbo.Production_History_Master WITH (NOLOCK) ON dbo.Production_History_Detail.Product_Id = dbo.Production_History_Master.Product_Id           
----LEFT JOIN dbo.Item_FinishGood_Master WITH (NOLOCK) ON dbo.Production_History_Master.Finish_Id = dbo.Item_FinishGood_Master.Finish_Id                                 
----WHERE Entry_Type IN ('Direct Repair','Sold Repair') AND (Production_History_Master.Branch_Id=@Branch_Id OR @Branch_Id = -1) AND CONVERT(DATE,dbo.Production_History_Master.Entry_Date) BETWEEN @FromDate AND @ToDate                                       
----AND Material_Type = 'Metal'  AND Setting_Id IN (SELECT * FROM  dbo.HDSplit(@Setting_Id ))                             
----GROUP BY Metal_Type             
----HAVING SUM(Weight) > 0                                             
                             
                                                  
----- Customer Tag Repair Material Wise Diamond Detail  
--SELECT Shape_Name,Purity_Name,Size_Name , SUM(tp.Dia_Wt) Cts FROM (  
--SELECT Shape_Id,dbo.Production_History_Detail.Purity_Id,Size_Id,SUM(CASE WHEN ISNULL(Weight,0)<0 THEN 0 ELSE ISNULL(Weight,0) END) AS Dia_Wt,  
--SUM(CASE WHEN ISNULL(Pcs,0)<0 THEN 0 ELSE ISNULL(Pcs,0) END) AS DiaPcs,ROUND(SUM(Weight)/5,3)DiaGram  
--FROM dbo.Production_History_Master WITH (NOLOCK)    
--LEFT JOIN dbo.Item_FinishGood_Master WITH (NOLOCK) ON  dbo.Production_History_Master.Finish_Id = dbo.Item_FinishGood_Master.Finish_Id  
--LEFT JOIN Production_History_Detail WITH (NOLOCK) ON Production_History_Detail.Product_Id = dbo.Production_History_Master.Product_Id AND Production_History_Detail.Finish_Id = dbo.Production_History_Master.Finish_Id AND Material_Type = 'Diamond'    
--WHERE Entry_Type IN ('Direct Repair','Sold Repair') AND (Production_History_Master.Branch_Id=@Branch_Id OR @Branch_Id = -1) AND CONVERT(DATE,dbo.Production_History_Master.Entry_Date) BETWEEN @FromDate AND @ToDate     
--AND Setting_Id IN (SELECT * FROM  dbo.HDSplit(@Setting_Id )) AND Item_FinishGood_Master.TagNo = CASE WHEN @TagNo <>'' THEN  @TagNo ELSE Item_FinishGood_Master.TagNo END  
--GROUP BY Shape_Id,dbo.Production_History_Detail.Purity_Id,Size_Id  
--UNION ALL  
--SELECT Shape_Id,dbo.Production_History_Detail.Purity_Id,Size_Id,SUM(Weight)*-1 AS Dia_Wt,SUM(Pcs)*-1 AS DiaPcs,ROUND(SUM(Weight)/5,3)*-1 DiaGram  
--FROM dbo.Production_History_Master WITH (NOLOCK)  
--LEFT JOIN dbo.Item_FinishGood_Master WITH (NOLOCK) ON  dbo.Production_History_Master.Finish_Id = dbo.Item_FinishGood_Master.Finish_Id    
--INNER JOIN dbo.Production_History_Master AS Repair WITH (NOLOCK)  ON Repair.Entry_Type IN ('Direct Repair','Sold Repair') AND dbo.Production_History_Master.Finish_Id = Repair.Finish_Id   
--AND CONVERT(DATE, dbo.Production_History_Master.Entry_Date) = CONVERT(DATE,Repair.Entry_Date)  
--LEFT JOIN Production_History_Detail WITH (NOLOCK) ON Production_History_Detail.Product_Id = dbo.Production_History_Master.Product_Id AND Production_History_Detail.Finish_Id = dbo.Production_History_Master.Finish_Id AND Material_Type = 'Diamond'    
--WHERE Production_History_Master.Entry_Type IN ('Voucher Entry') AND (Production_History_Master.Branch_Id=@Branch_Id OR @Branch_Id = -1) AND CONVERT(DATE,dbo.Production_History_Master.Entry_Date) BETWEEN @FromDate AND @ToDate   
--AND Setting_Id IN (SELECT * FROM  dbo.HDSplit(@Setting_Id )) AND Item_FinishGood_Master.TagNo = CASE WHEN @TagNo <>'' THEN  @TagNo ELSE Item_FinishGood_Master.TagNo END  
--GROUP BY Shape_Id,dbo.Production_History_Detail.Purity_Id,Size_Id  
--UNION ALL  
--SELECT Shape_Id,dbo.Production_History_Detail.Purity_Id,Size_Id,SUM(Weight) AS Dia_Wt,SUM(Pcs)AS DiaPcs,ROUND(SUM(Weight)/5,3)DiaGram  
--FROM dbo.Production_History_Master WITH (NOLOCK)    
--LEFT JOIN dbo.Item_FinishGood_Master WITH (NOLOCK) ON  dbo.Production_History_Master.Finish_Id = dbo.Item_FinishGood_Master.Finish_Id    
--INNER JOIN dbo.Production_History_Master AS Repair WITH (NOLOCK)  ON Repair.Entry_Type IN ('Direct Repair','Sold Repair') AND dbo.Production_History_Master.Finish_Id = Repair.Finish_Id  
--AND CONVERT(DATE,dbo.Production_History_Master.Entry_Date) = CONVERT(DATE,Repair.Entry_Date)  
--LEFT JOIN Production_History_Detail WITH (NOLOCK) ON Production_History_Detail.Product_Id = dbo.Production_History_Master.Product_Id AND Production_History_Detail.Finish_Id = dbo.Production_History_Master.Finish_Id AND Material_Type = 'Diamond'    
--WHERE dbo.Production_History_Master.Entry_Type IN ('Voucher Reverse') AND (Production_History_Master.Branch_Id=@Branch_Id OR @Branch_Id = -1) AND CONVERT(DATE,dbo.Production_History_Master.Entry_Date) BETWEEN @FromDate AND @ToDate   
--AND Setting_Id IN (SELECT * FROM  dbo.HDSplit(@Setting_Id )) AND Item_FinishGood_Master.TagNo = CASE WHEN @TagNo <>'' THEN  @TagNo ELSE Item_FinishGood_Master.TagNo END  
--GROUP BY Shape_Id,dbo.Production_History_Detail.Purity_Id,Size_Id   
--) AS tp  
--LEFT JOIN dbo.M_Diamond WITH (NOLOCK) ON dbo.M_Diamond.Diamond_ID = tp.Shape_Id                                   
--LEFT JOIN dbo.M_Purity WITH (NOLOCK) ON dbo.M_Purity.Purity_ID = tp.Purity_Id                                                                  
--LEFT JOIN dbo.M_Size WITH (NOLOCK) ON dbo.M_Size.Size_ID = tp.Size_Id   
--GROUP BY  Shape_Name,Purity_Name,Size_Name                                                          
--HAVING SUM(tp.Dia_Wt) <> 0                                                    
----SELECT Shape_Name,Purity_Name,Size_Name,SUM(Weight) Cts FROM dbo.Production_History_Detail WITH (NOLOCK)                                      
----LEFT JOIN dbo.M_Diamond WITH (NOLOCK) ON dbo.M_Diamond.Diamond_ID = dbo.Production_History_Detail.Shape_Id                                                                        
----LEFT JOIN dbo.M_Purity WITH (NOLOCK) ON dbo.M_Purity.Purity_ID = dbo.Production_History_Detail.Purity_Id                                                                        
----LEFT JOIN dbo.M_Size WITH (NOLOCK) ON dbo.M_Size.Size_ID = dbo.Production_History_Detail.Size_Id                                           
----LEFT JOIN dbo.Production_History_Master WITH (NOLOCK) ON dbo.Production_History_Detail.Product_Id = dbo.Production_History_Master.Product_Id          
----LEFT JOIN dbo.Item_FinishGood_Master WITH (NOLOCK) ON dbo.Production_History_Master.Finish_Id = dbo.Item_FinishGood_Master.Finish_Id                                                             
----WHERE Entry_Type  IN ('Direct Repair','Sold Repair') AND (Production_History_Master.Branch_Id=@Branch_Id OR @Branch_Id = -1) AND CONVERT(DATE,dbo.Production_History_Master.Entry_Date) BETWEEN @FromDate AND @ToDate                                       
----AND Material_Type = 'Diamond' AND Setting_Id IN (SELECT * FROM  dbo.HDSplit(@Setting_Id ))                                     
----GROUP BY Shape_Name,Purity_Name,Size_Name                                      
----HAVING SUM(Weight) > 0                                                  
                                                  
                                             
----- Customer Tag Repair Material Wise Other Detail       
--SELECT 'Stone' AS MType,CASE WHEN SUM(tp.Stone_Wt)<0 THEN 0 ELSE SUM(tp.Stone_Wt) END  As Weight   
--FROM #tempCustTagRepFinal AS tp  
--LEFT JOIN dbo.Item_FinishGood_Master WITH (NOLOCK) ON Item_FinishGood_Master.Finish_Id=tp.Finish_Id  
--WHERE Setting_Id IN (SELECT * FROM  dbo.HDSplit(@Setting_Id )) AND Item_FinishGood_Master.TagNo = CASE WHEN @TagNo <>'' THEN  @TagNo ELSE Item_FinishGood_Master.TagNo END                                                                                    
  
                      
--HAVING SUM(tp.Gross_Wt) <> 0 AND CASE WHEN SUM(tp.Stone_Wt)<0 THEN 0 ELSE SUM(tp.Stone_Wt) END <> 0   
--UNION ALL  
--SELECT 'Other' AS MType,CASE WHEN SUM(tp.Other_Wt)<0 THEN 0 ELSE SUM(tp.Other_Wt) END As Weight                      
--FROM #tempCustTagRepFinal AS tp  
--LEFT JOIN dbo.Item_FinishGood_Master WITH (NOLOCK) ON Item_FinishGood_Master.Finish_Id=tp.Finish_Id  
--WHERE Setting_Id IN (SELECT * FROM  dbo.HDSplit(@Setting_Id )) AND Item_FinishGood_Master.TagNo = CASE WHEN @TagNo <>'' THEN  @TagNo ELSE Item_FinishGood_Master.TagNo END                                                                                     
  
                     
--HAVING SUM(tp.Gross_Wt) <> 0 AND CASE WHEN SUM(tp.Other_Wt)<0 THEN 0 ELSE SUM(tp.Other_Wt) END <> 0                                           
----SELECT Material_Type AS MType,SUM(Weight) Weight FROM dbo.Production_History_Detail WITH (NOLOCK)                                      
----LEFT JOIN dbo.Production_History_Master WITH (NOLOCK) ON dbo.Production_History_Detail.Product_Id = dbo.Production_History_Master.Product_Id           
----LEFT JOIN dbo.Item_FinishGood_Master WITH (NOLOCK) ON dbo.Production_History_Master.Finish_Id = dbo.Item_FinishGood_Master.Finish_Id                                
----WHERE Entry_Type IN ('Direct Repair','Sold Repair') AND (Production_History_Master.Branch_Id=@Branch_Id OR @Branch_Id = -1) AND CONVERT(DATE,dbo.Production_History_Master.Entry_Date) BETWEEN @FromDate AND @ToDate                                       
----AND Material_Type IN ( 'Stone','Other' ) AND Setting_Id IN (SELECT * FROM  dbo.HDSplit(@Setting_Id ))                                     
----GROUP BY Material_Type                                       
----HAVING SUM(Weight) > 0                                                 
                                                  
    
                                                          
END   