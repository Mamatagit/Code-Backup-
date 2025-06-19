
WITH filtered_versions AS (
    SELECT 
        v.name,
        v.creation,
        v.owner,
        v.ref_doctype,
        v.docname,
        v.data
    FROM `tabVersion` v
    WHERE  
        v.creation >= CURDATE()
        AND EXISTS (
            SELECT 1 
            FROM `tabEmployee` e 
            WHERE e.user_id = v.owner
            AND e.company = 'Gurukrupa Export Private Limited'
        )
    ORDER BY v.creation DESC
    LIMIT 100000 -- Adjust to control how many rows you parse
)

SELECT
    fv.creation AS "Timestamp:Datetime",
    fv.owner AS "User",
    e.employee_name AS "Employee",
    e.company AS "Company",
    e.branch AS "Branch",
    e.department AS "Department",
    fv.ref_doctype AS "Doctype",
    changes.Field_Name AS "Field Value",
    changes.Old_Value AS "Old Value",
    changes.New_Value AS "New Value"
FROM filtered_versions fv
JOIN `tabEmployee` e ON fv.owner = e.user_id
JOIN JSON_TABLE(
    JSON_EXTRACT(fv.data, '$.changed'),
    "$[*]" COLUMNS (
        Field_Name VARCHAR(255) PATH "$[0]", 
        Old_Value VARCHAR(255) PATH "$[1]", 
        New_Value VARCHAR(255) PATH "$[2]"
    )
) AS changes
ORDER BY fv.creation DESC;



-----final code

WITH filtered_versions AS (
    SELECT 
        v.name,
        v.creation,
        v.owner,
        v.ref_doctype,
        v.docname,
        v.data
    FROM `tabVersion` v
    WHERE  
        v.creation >= CURDATE()
        AND EXISTS (
            SELECT 1 
            FROM `tabEmployee` e 
            WHERE e.user_id = v.owner
            AND e.company = 'Gurukrupa Export Private Limited'
        )
    ORDER BY v.creation DESC
    LIMIT 100000
)

SELECT
    fv.creation AS "Timestamp:Datetime",
    fv.owner AS "User",
    e.employee_name AS "Employee",
    e.company AS "Company",
    e.branch AS "Branch",
    e.department AS "Department",
    fv.ref_doctype AS "Doctype",
    fv.docname AS "Document ID (name field)",  -- This is the actual ID used in ERPNext tables
    changes.Field_Name AS "Field Changed",
    changes.Old_Value AS "Old Value",
    changes.New_Value AS "New Value"
FROM filtered_versions fv
JOIN `tabEmployee` e ON fv.owner = e.user_id
JOIN JSON_TABLE(
    JSON_EXTRACT(fv.data, '$.changed'),
    "$[*]" COLUMNS (
        Field_Name VARCHAR(255) PATH "$[0]", 
        Old_Value VARCHAR(255) PATH "$[1]", 
        New_Value VARCHAR(255) PATH "$[2]"
    )
) AS changes
ORDER BY fv.creation DESC;
