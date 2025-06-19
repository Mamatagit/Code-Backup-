sale gk



Declare @FromSale_Date Date = '2020-06-01',
@ToSale_Date Date = '2021-06-01',

@FromCredit_Date Date = '2020-05-01',
@ToCredit_Date Date = '2021-05-31'

Select * into #tempGold from (        
 SELECT Sales_Invoice_Master.Cust_ID,SUM(ROUND((ISNULL(MC1_Wt,0)  * ISNULL(MC1_Touch,0)) +(ISNULL(CHMC1_Wt,0)  * ISNULL(CHMC1_Touch,0)),3)) AS Sale_Weight ,0 Credit_Weight            
 FROM  dbo.Sales_Invoice_Rate_Detail WITH ( NOLOCK )        
 LEFT JOIN Sales_Invoice_Master WITH ( NOLOCK ) ON Sales_Invoice_Rate_Detail.Sale_ID = Sales_Invoice_Master.Sale_ID         
 WHERE  Convert(Date, Sales_Invoice_Master.SaleDate)  Between @FromSale_Date and @ToSale_Date          
 GROUP BY Sales_Invoice_Master.Cust_ID        
UNION ALL  
SELECT dbo.Sales_Invoice_Master_New.Cust_ID,SUM(ROUND((ISNULL(MC1_Wt,0)  * ISNULL(MC1_Touch,0)) +(ISNULL(CHMC1_Wt,0)  * ISNULL(CHMC1_Touch,0)),3)) AS Sale_Weight ,0 Credit_Weight            
 FROM  dbo.Sales_Invoice_Rate_Detail_New WITH ( NOLOCK )        
 LEFT JOIN dbo.Sales_Invoice_Master_New WITH ( NOLOCK ) ON dbo.Sales_Invoice_Rate_Detail_New.Sale_ID = dbo.Sales_Invoice_Master_New.Sale_ID  
 WHERE  Convert(Date, dbo.Sales_Invoice_Master_New.SaleDate)  Between @FromSale_Date and @ToSale_Date          
 GROUP BY dbo.Sales_Invoice_Master_New.Cust_ID  
          
union all         
         
 SELECT CreditNote_Transfer_Master.Cust_ID,0 AS Sale_Weight ,SUM(ROUND((ISNULL(MC1_Wt,0)  * ISNULL(MC1_Touch,0)) +(ISNULL(CHMC1_Wt,0)  * ISNULL(CHMC1_Touch,0)),3)) Credit_Weight          
 FROM  dbo.CreditNote_Rate_Detail WITH (NOLOCK)        
 LEFT JOIN  CreditNote_Transfer_Master ON dbo.CreditNote_Rate_Detail.Credit_Transfer_ID = dbo.CreditNote_Transfer_Master.Credit_Transfer_ID        
WHERE  Convert(Date, CreditNote_Transfer_Master.Transfer_Date)  Between  @FromCredit_Date and @ToCredit_Date          
GROUP BY CreditNote_Transfer_Master.Cust_ID        
        
union all          
        
 SELECT CreditNote_Purchase_Master.Party_Id,0 AS Sale_Weight ,SUM(ROUND((ISNULL(MC1_Wt,0)  * ISNULL(MC1_Touch,0)) +(ISNULL(CHMC1_Wt,0)  * ISNULL(CHMC1_Touch,0)),3))  Credit_Weight          
 FROM  dbo.CreditNote_Purchase_Rate_Detail WITH (NOLOCK)        
 LEFT JOIN  CreditNote_Purchase_Master ON dbo.CreditNote_Purchase_Rate_Detail.PurchaseId = dbo.CreditNote_Purchase_Master.InvoiceId        
WHERE  Convert(Date, CreditNote_Purchase_Master.Invoice_Date)  Between  @FromCredit_Date and @ToCredit_Date          
GROUP BY CreditNote_Purchase_Master.Party_Id        
UNION ALL  
SELECT dbo.CreditNote_Purchase_Master_New.Party_Id AS Party_Id,0 AS Sale_Weight ,SUM(ROUND((ISNULL(MC1_Wt,0)  * ISNULL(MC1_Touch,0)) +(ISNULL(CHMC1_Wt,0)  * ISNULL(CHMC1_Touch,0)),3))  Credit_Weight          
 FROM  dbo.CreditNote_Purchase_Rate_Detail_New WITH (NOLOCK)        
 LEFT JOIN  dbo.CreditNote_Purchase_Master_New ON dbo.CreditNote_Purchase_Rate_Detail_New.PurchaseId = dbo.CreditNote_Purchase_Master_New.CreditNotePurchase_Id  
WHERE  Convert(Date, dbo.CreditNote_Purchase_Master_New.Invoice_Date)  Between  @FromCredit_Date and @ToCredit_Date          
GROUP BY dbo.CreditNote_Purchase_Master_New.Party_Id  
        
union all          
        
 SELECT Item_Purchase_Master.Party_Id,0 AS Sale_Weight ,SUM(ROUND((ISNULL(MC1_Wt,0)  * ISNULL(MC1_Touch,0)) +(ISNULL(CHMC1_Wt,0)  * ISNULL(CHMC1_Touch,0)),3))  Credit_Weight          
 FROM  dbo.Item_Purchase_Rate_Detail WITH (NOLOCK)        
 LEFT JOIN  Item_Purchase_Master ON dbo.Item_Purchase_Rate_Detail.PurchaseId = dbo.Item_Purchase_Master.InvoiceId        
WHERE  Convert(Date, Item_Purchase_Master.Invoice_Date)  Between  @FromCredit_Date and @ToCredit_Date          
GROUP BY Item_Purchase_Master.Party_Id        
UNION ALL  
 SELECT Material_Purchase_Master_New.Ledger_Id AS Party_Id,0 AS Sale_Weight ,SUM(ROUND((ISNULL(MC1_Wt,0)  * ISNULL(MC1_Touch,0)) +(ISNULL(CHMC1_Wt,0)  * ISNULL(CHMC1_Touch,0)),3))  Credit_Weight          
 FROM  dbo.Item_Purchase_Rate_Detail_New WITH (NOLOCK)        
 LEFT JOIN  dbo.Material_Purchase_Master_New ON dbo.Item_Purchase_Rate_Detail_New.PurchaseId = dbo.Material_Purchase_Master_New.MPurchase_Id  
WHERE Purchase_Type='ITEM' AND Convert(Date, Material_Purchase_Master_New.Invoice_Date)  Between  @FromCredit_Date and @ToCredit_Date          
GROUP BY Material_Purchase_Master_New.Ledger_Id        
      
) As m1          
          
Select Cust_Name,Cust_Code,Sum(Sale_Weight) Sale_Weight,Sum(Credit_Weight) Credit_Weight,Sum(Sale_Weight) - Sum(Credit_Weight) As RealSale,          
Convert(Decimal(18,2), case when Sum(Sale_Weight) = 0 then 0 else (Sum(Credit_Weight)*100)/Sum(Sale_Weight) End) As Per,          
0.0 Sale_Amount,0.0 Credit_Amount,0.0 FinalAmount          
from #tempGold          
left join M_Customer with (Nolock) on M_Customer.Cust_Id = #tempGold.Cust_Id          
Group by Cust_Name,Cust_Code          
          
Drop table #tempGold 