DECLARE @FromDate AS DATE = '2022-04-01',
        @ToDate AS DATE = CAST(GETDATE() AS DATE);

SELECT 
    COUNT(Item_FinishGood_Master.TagNo) AS Tag_no,
    tp.Entry_Date AS Pro_Date
FROM (
    SELECT CONVERT(DATE, Entry_Date) Entry_Date, Finish_Id,
           ISNULL(Gold_Wt,0) + ISNULL(Chain_Wt,0) + ISNULL(DiaGram,0) + ISNULL(StoneGram,0) + ISNULL(Other_Wt,0) AS Gross_Wt
    FROM (
        SELECT Finish_Id, CONVERT(DATE, Entry_Date) AS Entry_Date,
               mGold.Gold_Wt, mChain.Chain_Wt, mDia.DiaGram, mStone.StoneGram, mOther.Other_Wt
        FROM dbo.Production_History_Master WITH (NOLOCK)
        OUTER APPLY (
            SELECT SUM(Weight) AS Gold_Wt
            FROM dbo.Production_History_Detail WITH (NOLOCK)
            LEFT JOIN dbo.M_Metal WITH (NOLOCK) ON M_Metal.Metal_ID = Production_History_Detail.Purity_Id
            WHERE Production_History_Detail.Product_Id = Production_History_Master.Product_Id 
              AND Production_History_Detail.Finish_Id = Production_History_Master.Finish_Id 
              AND Material_Type = 'Metal' AND Metal_Name = 'METAL'
        ) AS mGold
        OUTER APPLY (
            SELECT SUM(Weight) AS Chain_Wt
            FROM dbo.Production_History_Detail WITH (NOLOCK)
            LEFT JOIN dbo.M_Metal WITH (NOLOCK) ON M_Metal.Metal_ID = Production_History_Detail.Purity_Id
            WHERE Production_History_Detail.Product_Id = Production_History_Master.Product_Id 
              AND Production_History_Detail.Finish_Id = Production_History_Master.Finish_Id 
              AND Material_Type = 'Metal' AND Metal_Name = 'CHAIN'
        ) AS mChain
        OUTER APPLY (
            SELECT ROUND(SUM(Weight)/5,3) AS DiaGram
            FROM dbo.Production_History_Detail WITH (NOLOCK)
            WHERE Product_Id = Production_History_Master.Product_Id 
              AND Finish_Id = Production_History_Master.Finish_Id 
              AND Material_Type = 'Diamond'
        ) AS mDia
        OUTER APPLY (
            SELECT ROUND(SUM(Weight)/5,3) AS StoneGram
            FROM dbo.Production_History_Detail WITH (NOLOCK)
            WHERE Product_Id = Production_History_Master.Product_Id 
              AND Finish_Id = Production_History_Master.Finish_Id 
              AND Material_Type = 'Stone'
        ) AS mStone
        OUTER APPLY (
            SELECT SUM(Weight) AS Other_Wt
            FROM dbo.Production_History_Detail WITH (NOLOCK)
            WHERE Product_Id = Production_History_Master.Product_Id 
              AND Finish_Id = Production_History_Master.Finish_Id 
              AND Material_Type = 'Other'
        ) AS mOther
        WHERE Entry_Type = 'Production'
          AND CONVERT(DATE, Entry_Date) BETWEEN @FromDate AND @ToDate
    ) AS m1

    UNION ALL

    SELECT CONVERT(DATE, Entry_Date) Entry_Date, Finish_Id,
           ISNULL(Gold_Wt,0) + ISNULL(Chain_Wt,0) + ISNULL(DiaGram,0) + ISNULL(StoneGram,0) + ISNULL(Other_Wt,0) AS Gross_Wt
    FROM (
        SELECT Finish_Id, CONVERT(DATE, Entry_Date) AS Entry_Date,
               mGold.Gold_Wt, mChain.Chain_Wt, mDia.DiaGram, mStone.StoneGram, mOther.Other_Wt
        FROM JwelexMfg23..Production_History_Master WITH (NOLOCK)
        OUTER APPLY (
            SELECT SUM(Weight) AS Gold_Wt
            FROM JwelexMfg23..Production_History_Detail WITH (NOLOCK)
            LEFT JOIN JwelexMfg23..M_Metal WITH (NOLOCK) ON M_Metal.Metal_ID = Production_History_Detail.Purity_Id
            WHERE Production_History_Detail.Product_Id = Production_History_Master.Product_Id 
              AND Production_History_Detail.Finish_Id = Production_History_Master.Finish_Id 
              AND Material_Type = 'Metal' AND Metal_Name = 'METAL'
        ) AS mGold
        OUTER APPLY (
            SELECT SUM(Weight) AS Chain_Wt
            FROM JwelexMfg23..Production_History_Detail WITH (NOLOCK)
            LEFT JOIN JwelexMfg23..M_Metal WITH (NOLOCK) ON M_Metal.Metal_ID = Production_History_Detail.Purity_Id
            WHERE Production_History_Detail.Product_Id = Production_History_Master.Product_Id 
              AND Production_History_Detail.Finish_Id = Production_History_Master.Finish_Id 
              AND Material_Type = 'Metal' AND Metal_Name = 'CHAIN'
        ) AS mChain
        OUTER APPLY (
            SELECT ROUND(SUM(Weight)/5,3) AS DiaGram
            FROM JwelexMfg23..Production_History_Detail WITH (NOLOCK)
            WHERE Product_Id = Production_History_Master.Product_Id 
              AND Finish_Id = Production_History_Master.Finish_Id 
              AND Material_Type = 'Diamond'
        ) AS mDia
        OUTER APPLY (
            SELECT ROUND(SUM(Weight)/5,3) AS StoneGram
            FROM JwelexMfg23..Production_History_Detail WITH (NOLOCK)
            WHERE Product_Id = Production_History_Master.Product_Id 
              AND Finish_Id = Production_History_Master.Finish_Id 
              AND Material_Type = 'Stone'
        ) AS mStone
        OUTER APPLY (
            SELECT SUM(Weight) AS Other_Wt
            FROM JwelexMfg23..Production_History_Detail WITH (NOLOCK)
            WHERE Product_Id = Production_History_Master.Product_Id 
              AND Finish_Id = Production_History_Master.Finish_Id 
              AND Material_Type = 'Other'
        ) AS mOther
        WHERE Entry_Type = 'Production'
          AND CONVERT(DATE, Entry_Date) BETWEEN @FromDate AND @ToDate
    ) AS m2
) AS tp
LEFT JOIN dbo.Item_FinishGood_Master WITH (NOLOCK) ON Item_FinishGood_Master.Finish_Id = tp.Finish_Id
WHERE tp.Gross_Wt <> 0
GROUP BY tp.Entry_Date
ORDER BY tp.Entry_Date Desc;
