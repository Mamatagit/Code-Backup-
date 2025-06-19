SELECT name as 'Project ID' ,project_name as Project,priority as Priority,
project_type as 'Project Type', 
    company as Company,
    DATE(creation) as 'Created on',
    expected_start_date as 'Project Started',
    expected_end_date as 'Project End',
    is_active,
    message as Message,
    notes as Notes,
    CASE 
        WHEN status = 0 THEN 'Open'
        ELSE status
    END AS project_status,
    percent_complete as 'Project Completion' ,
    
 GROUP_CONCAT(
        DISTINCT 
        SUBSTRING_INDEX(
            SUBSTRING_INDEX(jt.email, '@', 1),  -- strip off “@domain”
            '_',                                -- then split on “_”
            1                                   -- take the first element
        )
        ORDER BY jt.rowid
        SEPARATOR ', '
    ) AS 'Assigned Employees',
 TIMESTAMPDIFF(MONTH, CURDATE(), expected_end_date) AS 'Months to Completion'
FROM  `tabProject`
    CROSS JOIN JSON_TABLE(
        _assign,
        '$[*]' COLUMNS (
            rowid FOR ORDINALITY,            -- preserves the original array order
            email VARCHAR(255) PATH '$'      -- each element as `jt.email`
        )
    ) AS jt
WHERE
    owner = 'hjr@gkexport.com'
    
GROUP BY
company,
    creation,
    expected_start_date,
    expected_end_date,
    is_active,
    message,
    name,
    notes,
    percent_complete,
    project_status,
    project_type,
    priority,
    project_name;


----- final sql code with number of task clickble

SELECT 
    p.name as 'Project ID',
    p.project_name as Project,
    p.priority as Priority,
    p.project_type as 'Project Type', 
    p.company as Company,
    DATE(p.creation) as 'Created on',
    p.expected_start_date as 'Project Started',
    p.expected_end_date as 'Project End',
    p.is_active,
    p.message as Message,
    p.notes as Notes,
    CASE 
        WHEN p.status = 0 THEN 'Open'
        ELSE p.status
    END AS project_status,
    p.percent_complete as 'Project Completion',

    GROUP_CONCAT(
        DISTINCT 
        SUBSTRING_INDEX(
            SUBSTRING_INDEX(jt.email, '@', 1),
            '_',
            1
        )
        ORDER BY jt.rowid
        SEPARATOR ', '
    ) AS 'Assigned Employees',

    TIMESTAMPDIFF(MONTH, CURDATE(), p.expected_end_date) AS 'Months to Completion',

    CONCAT(
        '<a href="https://gkexport.frappe.cloud/app/task?project=',
        p.name,
        '" target="_blank">',
        COUNT(DISTINCT t.name),  -- COUNT distinct tasks
        '</a>'
    ) AS 'Number Of Task'

FROM 
    `tabProject` p
    
    LEFT JOIN `tabTask` t ON t.project = p.name

    CROSS JOIN JSON_TABLE(
        p._assign,  -- Explicitly reference _assign from tabProject
        '$[*]' COLUMNS (
            rowid FOR ORDINALITY,
            email VARCHAR(255) PATH '$'
        )
    ) AS jt

WHERE
    p.owner = 'hjr@gkexport.com'

GROUP BY
    p.company,
    p.creation,
    p.expected_start_date,
    p.expected_end_date,
    p.is_active,
    p.message,
    p.name,
    p.notes,
    p.percent_complete,
    project_status,
    p.project_type,
    p.priority,
    p.project_name;
