DECLARE @NroServ INT = 43158; -- << REEMPLAZAR SOLO ESTE NÚMERO

WITH 
-- 1. Total de traslados recibidos y devueltos por almacén
CTE_Traslados AS (
    SELECT 
        T1.ItemCode,
        T1.WhsCode AS Almacen,
        SUM(T1.Quantity) AS CantTraslado
    FROM OWTR T0
    INNER JOIN WTR1 T1 ON T0.DocEntry = T1.DocEntry
    WHERE T0.CANCELED = 'N' AND T0.U_NroServ = @NroServ AND T1.Quantity > 0
    GROUP BY T1.ItemCode, T1.WhsCode
),
-- 2. Balance neto de Facturación
CTE_Facturacion AS (
    SELECT 
        T1.ItemCode,
        T1.WhsCode AS Almacen,
        SUM(ISNULL(T1.Quantity, 0)) AS CantFacturada
    FROM OINV T0
    INNER JOIN INV1 T1 ON T0.DocEntry = T1.DocEntry
    WHERE T0.CANCELED = 'N' AND T0.U_NroServ = @NroServ
    GROUP BY T1.ItemCode, T1.WhsCode
),
-- 3. Balance de Notas de Crédito
CTE_NotasCredito AS (
    SELECT 
        T1.ItemCode,
        T1.WhsCode AS Almacen,
        SUM(ISNULL(T1.Quantity, 0)) AS CantNC
    FROM ORIN T0
    INNER JOIN RIN1 T1 ON T0.DocEntry = T1.DocEntry
    WHERE T0.CANCELED = 'N' AND T0.U_NroServ = @NroServ
    GROUP BY T1.ItemCode, T1.WhsCode
)

-- 4. Consolidación y evaluación de discrepancias
SELECT 
    ISNULL(T.ItemCode, ISNULL(F.ItemCode, NC.ItemCode)) AS Articulo,
    ISNULL(T.Almacen, ISNULL(F.Almacen, NC.Almacen)) AS AlmacenDestino,
    ISNULL(T.CantTraslado, 0) AS Cantidad_Trasladada,
    (ISNULL(F.CantFacturada, 0) - ISNULL(NC.CantNC, 0)) AS Cantidad_Facturada_Neta,
    
    CASE 
        -- Regla especial: Identifica mano de obra y cargos sin generar alerta de traslado
        WHEN ISNULL(T.ItemCode, ISNULL(F.ItemCode, NC.ItemCode)) LIKE 'CAR-%'
            THEN 'SERVICIO: Mano de obra / Cargo (No requiere traslado físico)'

        -- Evaluaciones para repuestos físicos
        WHEN ISNULL(T.CantTraslado, 0) > (ISNULL(F.CantFacturada, 0) - ISNULL(NC.CantNC, 0))
            THEN 'ALERTA: Repuestos trasladados sin facturar al cliente'
        WHEN ISNULL(T.CantTraslado, 0) < (ISNULL(F.CantFacturada, 0) - ISNULL(NC.CantNC, 0))
            THEN 'ALERTA: Repuestos facturados sin respaldo de traslado físico'
        ELSE 'CORRECTO: Inventario y Facturación Alineados'
    END AS Estado_Auditoria

FROM CTE_Traslados T
FULL OUTER JOIN CTE_Facturacion F 
    ON T.ItemCode = F.ItemCode AND T.Almacen = F.Almacen
FULL OUTER JOIN CTE_NotasCredito NC 
    ON COALESCE(T.ItemCode, F.ItemCode) = NC.ItemCode 
   AND COALESCE(T.Almacen, F.Almacen) = NC.Almacen
WHERE ISNULL(T.Almacen, ISNULL(F.Almacen, NC.Almacen)) NOT IN ('FIXIT-01', 'FIXIT-02', 'FIXIT-03', 'FIXIT-11', 'FIXIT-06', 'FIXIT-07');
