{{config(materialized = 'table')}}

/*
 *   WHEN         WHO            WHAT
 *   ------------ -------------- -----------------------------------------------
 *   29-JAN-2025  DEEKSHA         SNF-7926 INITIAL-Seed data
 *   29-JAN-2025  DEEKSHA         SNF-8253 Added segment names
 *
 */

with SRI_GCC as (
            SELECT
                 FIFS.ID_FLEX_NUM CHART_OF_ACCOUNTS_ID ,
                 FIFS.APPLICATION_COLUMN_NAME ,
                 FIFS.SEGMENT_NUM,
                 FIFS.SEGMENT_NAME,
                 FIFS.FLEX_VALUE_SET_ID,
                 FFVS.VALIDATION_TYPE,
                 FFV.FLEX_VALUE_ID, 
                 FFV.FLEX_VALUE,
                 FFVT.DESCRIPTION
               FROM {{ ref('stg_sri_fnd_id_flex_segments') }}  FIFS
               INNER JOIN {{ ref('stg_sri_fnd_flex_value_sets') }} FFVS
                 ON FFVS.FLEX_VALUE_SET_ID = FIFS.FLEX_VALUE_SET_ID
               INNER JOIN {{ ref('stg_sri_fnd_flex_values') }}   FFV
                 ON FFV.FLEX_VALUE_SET_ID = FIFS.FLEX_VALUE_SET_ID
               INNER JOIN {{ ref('stg_sri_fnd_flex_values_tl') }}  FFVT
                 ON FFV.FLEX_VALUE_ID = FFVT.FLEX_VALUE_ID
               WHERE 1=1
                 AND FIFS.APPLICATION_ID = '101'
                 AND FIFS.ID_FLEX_CODE = 'GL#'
                 AND FIFS.ENABLED_FLAG = 'Y'
                 AND APPLICATION_COLUMN_NAME='SEGMENT3'
                ),
SIS_GCC AS
(	       SELECT
		         FIFS.ID_FLEX_NUM CHART_OF_ACCOUNTS_ID ,
		         FIFS.APPLICATION_COLUMN_NAME ,
		         FIFS.SEGMENT_NUM,
		         FIFS.SEGMENT_NAME,
		         FIFS.FLEX_VALUE_SET_ID,
		         FFVS.VALIDATION_TYPE,
		         FFV.FLEX_VALUE_ID,
		         FFV.FLEX_VALUE,
		         FFVT.DESCRIPTION,
                 ROW_NUMBER() OVER(ORDER BY CHART_OF_ACCOUNTS_ID,FLEX_VALUE) row_num,
             CASE WHEN FFVNH.PARENT_FLEX_VALUE IS NOT NULL THEN 'P' ELSE 'C' END AS PARENT_CHILD_FLAG
		       FROM {{ ref('stg_sis_fnd_id_flex_segments') }}  FIFS
		       INNER JOIN  {{ ref('stg_sis_fnd_flex_value_sets') }} FFVS
		         ON FFVS.FLEX_VALUE_SET_ID = FIFS.FLEX_VALUE_SET_ID
		       INNER JOIN  {{ ref('stg_sis_fnd_flex_values') }}   FFV
		         ON FFV.FLEX_VALUE_SET_ID = FIFS.FLEX_VALUE_SET_ID
		       INNER JOIN  {{ ref('stg_sis_fnd_flex_values_tl') }}    FFVT
		         ON FFV.FLEX_VALUE_ID = FFVT.FLEX_VALUE_ID
           LEFT OUTER JOIN (
                SELECT DISTINCT FLEX_VALUE_SET_ID, PARENT_FLEX_VALUE 
                FROM  {{ ref('stg_sis_fnd_flex_value_norm_hierarchy') }} ) FFVNH
             ON FFV.FLEX_VALUE_SET_ID = FFVNH.FLEX_VALUE_SET_ID
             AND FFV.FLEX_VALUE = FFVNH.PARENT_FLEX_VALUE
		       WHERE 1=1
		         AND FIFS.APPLICATION_ID = '101'
		         AND FIFS.ID_FLEX_CODE = 'GL#'
		         AND FIFS.ENABLED_FLAG = 'Y'
                 AND APPLICATION_COLUMN_NAME='SEGMENT6'),

SRI AS (                
SELECT DISTINCT ACC.FUSION_ACCOUNT,ACC.EBS_ACCOUNT,SRI_GCC.DESCRIPTION AS ebs_account_description,SOURCE,
       F.SEGMENT3_NAME AS fusion_account_description 
FROM {{ ref('stg_reverse_bridge_account') }} ACC
LEFT JOIN SRI_GCC ON SRI_GCC.FLEX_VALUE =CAST(ACC.EBS_ACCOUNT AS STRING)
left join {{ ref('fusion_gl_code_combinations') }} F ON F.SEGMENT3=CAST(ACC.FUSION_ACCOUNT AS STRING)
WHERE SOURCE='SRI'
),
SIS AS (
SELECT DISTINCT ACC.FUSION_ACCOUNT,ACC.EBS_ACCOUNT,SIS_GCC.DESCRIPTION AS ebs_account_description,SOURCE,
       F.SEGMENT3_NAME AS fusion_account_description 
FROM {{ ref('stg_reverse_bridge_account') }}  ACC
LEFT JOIN SIS_GCC ON SIS_GCC.FLEX_VALUE =CAST(ACC.EBS_ACCOUNT AS STRING)
left join {{ ref('fusion_gl_code_combinations') }}  F ON F.SEGMENT3=CAST(ACC.FUSION_ACCOUNT AS STRING)
WHERE SOURCE='SIS'
)
SELECT DISTINCT *
FROM SIS
UNION 
SELECT DISTINCT *
FROM SRI