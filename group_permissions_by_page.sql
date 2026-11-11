WITH grp AS (
    SELECT
        g.id AS group_number,
        g.name AS group_name,
        NVL(g.valueli, 0) AS default_level
    FROM gen g
    WHERE
        g.cat = 'groups'
        AND g.id > 0
),
page_override AS (
    SELECT
        gr.group_number,
        gr.group_name,
        gr.default_level,
        p.path,
        CASE
            WHEN SUBSTR(p.security, gr.group_number, 1) = '2' THEN 2
            WHEN SUBSTR(p.security, gr.group_number, 1) = '1' THEN 1
            ELSE 0
        END AS page_level
    FROM grp gr
    INNER JOIN pages p ON SUBSTR(p.security, gr.group_number, 1) IN ('0', '1', '2')
)
SELECT
    po.group_number,
    po.group_name,
    CASE po.default_level WHEN 0 THEN 'No Access' WHEN 1 THEN 'Read Only' ELSE 'Edit' END AS group_default,
    po.path AS page_path,
    CASE po.page_level WHEN 0 THEN 'No Access' WHEN 1 THEN 'Read Only' ELSE 'Edit' END AS page_access,
    CASE WHEN po.page_level > po.default_level THEN 'More' ELSE 'Less' END AS compared_to_default
FROM page_override po
WHERE
    po.page_level != po.default_level
ORDER BY
    po.group_number,
    LOWER(po.path)
