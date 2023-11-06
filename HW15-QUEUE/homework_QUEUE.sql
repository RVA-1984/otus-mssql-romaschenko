--В качестве хранимой процедуры (Amount_agreement) создал процедуру из проекта, которая формирует отчет по договорам (id_agreement) по выданным кредитам
 USE credit_portfolio;

IF OBJECT_ID ( 'Amount_agreement', 'AA' ) IS NOT NULL
    DROP PROCEDURE Amount_agreement;
GO
CREATE PROCEDURE Amount_agreement 
     @id_agreement INT,
     @id_client INT,
	 @client_name VARCHAR (50),
	 @amount_agreement DECIMAL (18,2)
	
    
AS
    SET NOCOUNT ON;
    SELECT LP.id_agreement AS agreement, LP.id_client AS client, LP.client_name AS 'Name_client', amount_agreement AS 'amount_agreement'
    FROM dbo.loan_portfolio AS LP
    JOIN dbo.loan_agreement AS LA
      ON LA.id_agreement = LP.id_agreement
    WHERE LP.id_agreement LIKE  @id_agreement;
-- Populate the output variable @amount_agreement.
SET @amount_agreement = (SELECT SUM(amount_agreement)
    FROM dbo.loan_portfolio AS LP
    JOIN dbo.loan_agreement AS LA
      ON LA.id_agreement = LP.id_agreement
    WHERE LP.id_agreement LIKE  @id_agreement);
SET @id_agreement = @amount_agreement;
GO
 
 CREATE SERVICE [Amount_agreement]
       ON QUEUE Queue_Amount_agreement;
GO


CREATE QUEUE Queue_Amount_agreement
    WITH STATUS = ON
      , RETENTION = ON
      , ACTIVATION (
          PROCEDURE_NAME = Amount_agreement
          , MAX_QUEUE_READERS = 10
          , EXECUTE AS 'LAPTOP-CQGRG71V')
    ON [DEFAULT];