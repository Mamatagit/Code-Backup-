
select 'Production' as Type,'GK' as Company,Customer_Id,Category_Id,Sub_Category_Id,Setting_Id,sum(DCust_Weight)  
 Dia_wts,sum(GCust_Weight) Gold_wts from Item_FinishGood_Master WITH (NOLOCK) 
 
outer apply (select Finish_Id,sum(D.Cust_Weight) DCust_Weight from Item_FinishGood_Diamond_Detail  as D WITH (NOLOCK)  
    where D.Finish_Id = Item_FinishGood_Master.Finish_Id group by Finish_Id)  Diamond 
	
outer apply (select Finish_Id,sum(G.Cust_Weight*Metal_Ratio) GCust_Weight from Item_FinishGood_Gold_Detail as G WITH (NOLOCK)  
   left join M_Metal on M_Metal.Metal_ID = G.Metal_Id  
    where G.Finish_Id = Item_FinishGood_Master.Finish_Id group by Finish_Id)  Gold   

where Item_FinishGood_Master.Finish_Id in (  
select Finish_Id from Production_History_Master WITH (NOLOCK) 
where CONVERT (date,Entry_Date) between '2025-03-01' AND '2025-03-25'   
and Entry_Type = 'Voucher Entry' and Dia_Wt <> 0
)   

group by Customer_Id,Category_Id,Sub_Category_Id,Setting_Id 



Production 
job work gold diamond




sale
job work gold diamond

select 'Sale' as Type,'GK' as Company,Sales_Invoice_Master_New.Cust_ID as Customer_Id ,Item_FinishGood_Master.Category_Id,  
Item_FinishGood_Master.Sub_Category_Id,Item_FinishGood_Master.Setting_Id,sum(DCust_Weight) Dia_wts,sum(GCust_Weight) Gold_wts from Sales_Invoice_Item_Master_New WITH (NOLOCK)  
left join Item_FinishGood_Master WITH (NOLOCK) on Sales_Invoice_Item_Master_New.TagNo = Item_FinishGood_Master.TagNo  
outer apply (select Finish_Id,sum(D.Cust_Weight) DCust_Weight from Item_FinishGood_Diamond_Detail as D WITH (NOLOCK)  
    where D.Finish_Id = Item_FinishGood_Master.Finish_Id group by Finish_Id)  Diamond   
outer apply (select Finish_Id,sum(G.Cust_Weight*Metal_Ratio) GCust_Weight from Item_FinishGood_Gold_Detail as G WITH (NOLOCK)  
   left join M_Metal WITH (NOLOCK) on M_Metal.Metal_ID = G.Metal_Id  
   where G.Finish_Id = Item_FinishGood_Master.Finish_Id group by Finish_Id)  Gold   
left join Sales_Invoice_Master_New WITH (NOLOCK) on Sales_Invoice_Master_New.Sale_ID = Sales_Invoice_Item_Master_New.Sale_ID  
where  CONVERT (date,SaleDate) between '2025-03-01' AND '2025-03-25'   
and Item_FinishGood_Master.Finish_Id in (select Finish_Id from Production_History_Master WITH (NOLOCK) where CONVERT (date,Entry_Date) <= '2025-03-25'   
and Entry_Type = 'Voucher Entry' and Dia_Wt <> 0 )  
group by Sales_Invoice_Master_New.Cust_ID,Item_FinishGood_Master.Category_Id,Item_FinishGood_Master.Sub_Category_Id,Item_FinishGood_Master.Setting_Id  
