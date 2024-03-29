USE [master]
GO
/****** Object:  Database [SMSWeb]    Script Date: 02-06-2019 00:06:03 ******/
CREATE DATABASE [SMSWeb]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'SMSWeb', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.SQLEXPRESS\MSSQL\DATA\SMSWeb.mdf' , SIZE = 5184KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'SMSWeb_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.SQLEXPRESS\MSSQL\DATA\SMSWeb_log.ldf' , SIZE = 3520KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [SMSWeb] SET COMPATIBILITY_LEVEL = 110
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [SMSWeb].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [SMSWeb] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [SMSWeb] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [SMSWeb] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [SMSWeb] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [SMSWeb] SET ARITHABORT OFF 
GO
ALTER DATABASE [SMSWeb] SET AUTO_CLOSE ON 
GO
ALTER DATABASE [SMSWeb] SET AUTO_CREATE_STATISTICS ON 
GO
ALTER DATABASE [SMSWeb] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [SMSWeb] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [SMSWeb] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [SMSWeb] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [SMSWeb] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [SMSWeb] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [SMSWeb] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [SMSWeb] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [SMSWeb] SET  ENABLE_BROKER 
GO
ALTER DATABASE [SMSWeb] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [SMSWeb] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [SMSWeb] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [SMSWeb] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [SMSWeb] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [SMSWeb] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [SMSWeb] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [SMSWeb] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [SMSWeb] SET  MULTI_USER 
GO
ALTER DATABASE [SMSWeb] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [SMSWeb] SET DB_CHAINING OFF 
GO
ALTER DATABASE [SMSWeb] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [SMSWeb] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
USE [SMSWeb]
GO
/****** Object:  StoredProcedure [dbo].[MonthlySubsReportDetail]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



                                                                CREATE PROCEDURE [dbo].[MonthlySubsReportDetail] @Year INT,@Month INT,@BroadcasterID INT
                                                                        AS
                                                                        BEGIN
                                                                        
                    create table #t
                    (
                    YY int,
                    MM int,
                    ProductID int,
                    ProductName  NVARCHAR(50),
                    BroadcasterID int,
                    Opening int,
                    Active int,
                    Deactive int,
                    Closing int,
                    ProductType int,
                    )

                    DECLARE @DTBegin datetime;
                    SET @DTBegin=(SELECT MIN(CreateTime) FROM OrderProduct)
                                  DECLARE @MyYY INT ,@MyMM INT
			                      SET @MyYY=YEAR(@DTBegin);
			                      SET @MyMM=MONTH(@DTBegin);    
			                     DECLARE @MYDT NVARCHAR(50)
			                      SET @MYDT=CONVERT(nvarchar(10),@MyYY)+RIGHT('00'+CONVERT(nvarchar(10),@MyMM),2)+'01' 
			                                PRINT '------'+@MYDT+'--------'
			                      SET @DTBegin=CONVERT(DATETIME,@MYDT);
			                      DECLARE @TODAY DATETIME
			                      SET @TODAY=GETDATE();
                                    DECLARE @MYDTSel DATETIME--选择月的月末
			                       SET @MYDTSel=DATEADD(MONTH,1, CONVERT(nvarchar(10),@Year)+RIGHT('00'+CONVERT(nvarchar(10),@Month),2)+'01')
			                      IF (@Year=YEAR(@TODAY) AND @Month=MONTH(@TODAY))
			                       BEGIN
			                          SET @MYDTSel=GETDATE();
			                       END
                               WHILE @DTBegin<=@TODAY
                               BEGIN

                                  SET @MyYY=YEAR(@DTBegin);
			                      SET @MyMM=MONTH(@DTBegin);    
			                      SET @MYDT=CONVERT(nvarchar(10),@MyYY)+RIGHT('00'+CONVERT(nvarchar(10),@MyMM),2)+'01' 
			                                PRINT '------'+@MYDT+'--------'
			                       DECLARE @MYDT1 DATETIME--月初
			                       SET @MYDT1=CONVERT(DATETIME, @MYDT)
			                       DECLARE @MYDT2 DATETIME--月末
			                       SET @MYDT2=DATEADD(MONTH,1, @MYDT1)
                                    IF (@MyYY=YEAR(@TODAY) AND @MyMM=MONTH(@TODAY))
			                       BEGIN
			                          SET @MYDT2=GETDATE();
			                       END
			                        PRINT '-------@MYDT2------'
							                    insert into #t(YY,MM,ProductID,ProductName,ProductType,Opening,Active,Deactive,Closing)
							                    SELECT DISTINCT YY,MM,T.ProductID,ProductName,ProductType,0 as Opening,isnull([Actived],0) as [Actived],0 AS Deactive,isnull([Colosing],0) as [Colosing] FROM
                                                (
                                                  SELECT YY,MM,ProductID,0 AS BroadcasterID,0 AS Opening,[Actived],[Colosing]
                                                  FROM
                                                  (
								                    SELECT YY,MM,ProductID,CustCNT,OrderStatus FROM
								                    (
									                    SELECT YY,MM,P.ProductID,COUNT(DISTINCT [ICTableID])CustCNT,'Colosing' as OrderStatus from
										                      (
											                     SELECT * FROM
											                     (
                                                                    SELECT OP.[ID],[UserCostID],OP.[CustomerID]
                                                                  ,[ICTableID],[ProductID],[OrderFeePackageID],[PriceID],[Price],[PreferentialID],[Preferential],[OriginalFee],[RealFee]
                                                                  ,[OrderMonth],[AdjustDays],[OperateType],[RenewOriginateType],OP.[Status],[BackOrderID],OP.[Remark] ,OP.[Creator],OP.[CreateTime],OP.[LastEditor]
                                                                  ,OP.[LastEditTime],[StartDate],[EndDate],AuthTime  as [MyStartDate],UnauthTime as MyEndDate FROM OrderProduct OP
                                                                   INNER JOIN  ICCardInfo AS IC ON OP.ICTableID=IC.ID
                                                                    WHERE NOT EXISTS(SELECT ICInternalNumber FROM ICBlacklist ICB WHERE ICB.ICInternalNumber=IC.InternalNumber) AND OperateType=5  AND OP.LastEditTime<=EndDate
											                       ) AS OP
									                    WHERE   op.MyStartDate <@MYDT2
									                    AND op.MyEndDate >= @MYDT2
									                    ) AS T
									                    RIGHT  JOIN (
										                        SELECT DISTINCT @MyYY AS YY,@MyMM AS MM,Prd.ProductID,Prd.CAProductID FROM [ProductLog] Prd
											                    INNER JOIN 
											                    (
													                       SELECT CAProductID,MAX(ID)ID FROM  [ProductLog]
														                     WHERE CreateTime<=@MYDT2			                         
														                    GROUP BY CAProductID
														                    ) AS T
											                    ON Prd.ID=T.ID
											                    INNER JOIN [ProductProgramRelationLog] PPR ON PPR.ProductLogID=Prd.ID
											                    INNER JOIN ( SELECT ProgramID,MAX(ID)ID FROM  ProgramLog
														                       WHERE 
														                        CreateTime<=@MYDT2			                         
														                    GROUP BY ProgramID
											                    ) AS  prg ON prg.ProgramID=ppr.ProgramID
											                    INNER JOIN ProgramLog ON ProgramLog.ID=prg.ID
											                    WHERE ProgramLog.BroadcasterID=@BroadcasterID
									                    ) AS P ON P.ProductID=T.ProductID
									                    group by YY,MM,P.ProductID
    
								                    ) AS T1
								                    UNION 
								                    SELECT YY,MM,ProductID,CustCNT,OrderStatus FROM
								                    (
								
                                      
								
									                    SELECT YY,MM,P.ProductID,COUNT(DISTINCT [ICTableID])CustCNT,'Actived' as OrderStatus from
										                      (
											                     SELECT * FROM
											                     (
                                                                    SELECT OP.[ID],[UserCostID],OP.[CustomerID]
                                                                  ,[ICTableID],[ProductID],[OrderFeePackageID],[PriceID],[Price],[PreferentialID],[Preferential],[OriginalFee],[RealFee]
                                                                  ,[OrderMonth],[AdjustDays],[OperateType],[RenewOriginateType],OP.[Status],[BackOrderID],OP.[Remark] ,OP.[Creator],OP.[CreateTime],OP.[LastEditor]
                                                                  ,OP.[LastEditTime],[StartDate],[EndDate],AuthTime  as [MyStartDate],UnauthTime as MyEndDate FROM OrderProduct OP
                                                                   INNER JOIN  ICCardInfo AS IC ON OP.ICTableID=IC.ID
                                                                    WHERE NOT EXISTS(SELECT ICInternalNumber FROM ICBlacklist ICB WHERE ICB.ICInternalNumber=IC.InternalNumber) AND OperateType=5  AND OP.LastEditTime<=EndDate

											                       ) AS OP
									                    WHERE   YEAR(op.MyStartDate)=@MyYY AND MONTH(op.MyStartDate)=@MyMM
									                    ) AS T
									                    RIGHT  JOIN (
										                        SELECT DISTINCT @MyYY AS YY,@MyMM AS MM,Prd.ProductID,Prd.CAProductID FROM [ProductLog] Prd
											                    INNER JOIN 
											                    (
													                       SELECT CAProductID,MAX(ID)ID FROM  [ProductLog]
														                     WHERE CreateTime<=@MYDT2			                         
														                    GROUP BY CAProductID
														                    ) AS T
											                    ON Prd.ID=T.ID
											                    INNER JOIN [ProductProgramRelationLog] PPR ON PPR.ProductLogID=Prd.ID
											                    INNER JOIN ( SELECT ProgramID,MAX(ID)ID FROM  ProgramLog
														                       WHERE 
														                        CreateTime<=@MYDT2			                         
														                    GROUP BY ProgramID
											                    ) AS  prg ON prg.ProgramID=ppr.ProgramID
											                    INNER JOIN ProgramLog ON ProgramLog.ID=prg.ID
											                    WHERE ProgramLog.BroadcasterID=@BroadcasterID
									                    ) AS P ON P.ProductID=T.ProductID
									                    group by YY,MM,P.ProductID
    
								                    ) AS T1
						                       ) AS P
							                    PIVOT
							                    (
							                     SUM(CustCNT)
							                     FOR OrderStatus in([Actived],[Colosing])
							                    )AS PVT

							                    ) AS T
							                    INNER JOIN ProductInfo ON ProductInfo.ProductID=T.ProductID
                                                WHERE (Opening+[Actived]+[Colosing])>0
                            SET @DTBegin=DATEADD(MONTH,1,@DTBegin)                    
		                    END
	
		                    --truncate table #t
		                    --更新数据OPENING
		                    --先找到全部产品
		                    DECLARE @MYProductID INT
		                    DECLARE ProductIDCursor CURSOR FOR 
		                    select DISTINCT ProductID  from #t

		                    OPEN ProductIDCursor;
		                    FETCH NEXT FROM ProductIDCursor INTO 
		                    @MYProductID
		                    WHILE @@FETCH_STATUS = 0
			                    BEGIN
			                        DECLARE @YY INT,@MM INT,@ProductID INT,@ProductName nvarchar(50),@ProductType INT,@Opening INT,@Active INT,@Deactive INT,@Closing INT
				                    DECLARE ProductCursor CURSOR FOR 
				                    select YY,MM,ProductID,ProductName,ProductType,0 as Opening,Active,Deactive,Closing from #t
				                    WHERE ProductID=@MYProductID
				                    ORDER BY YY,MM
				                    OPEN ProductCursor;
				                    FETCH NEXT FROM ProductCursor INTO 
				                    @YY ,@MM ,@ProductID ,@ProductName,@ProductType ,@Opening ,@Active ,@Deactive,@Closing 
				                    WHILE @@FETCH_STATUS = 0
					                    begin
					                    DECLARE @DT DATETIME
					                    SET @DT=CONVERT(nvarchar(50),@YY)+RIGHT('00'+CONVERT(nvarchar(50),@MM),2)+'01'
					                    PRINT 'DT:'+ CONVERT(nvarchar(50),@DT,120)
					                    IF  EXISTS(     SELECT TOP 1 * FROM #t WHERE ProductID=@MYProductID AND CONVERT(DATETIME,CONVERT(nvarchar(50),YY)+RIGHT('00'+CONVERT(nvarchar(50),MM),2)+'01')<@DT
					                    ORDER BY YY DESC,MM DESC)
					                    BEGIN
					                      PRINT ' EXISTS'
					                      PRINT 'begin---------'
					                    PRINT CONVERT(NVARCHAR(50),@YY) +' '+CONVERT(NVARCHAR(50),@MM)  +' '+CONVERT(NVARCHAR(50),@ProductID) +' '+CONVERT(NVARCHAR(50),@ProductName) +' '+CONVERT(NVARCHAR(50),@ProductType) +' '+CONVERT(NVARCHAR(50),@Opening)  +' '+CONVERT(NVARCHAR(50),@Active) +' '+CONVERT(NVARCHAR(50),@Deactive )

					                     PRINT 'end---------'
					                      DECLARE @AA INT
					                      SET @AA=(SELECT TOP 1 Closing FROM #t WHERE ProductID=@MYProductID AND CONVERT(DATETIME,CONVERT(nvarchar(50),YY)+RIGHT('00'+CONVERT(nvarchar(50),MM),2)+'01')<@DT
						                    ORDER BY YY DESC,MM DESC)
						                    PRINT 'last Opening @AA'
					                      PRINT @AA
					                      --PRINT 'CLOSING'
					                      --PRINT Closing
					                      UPDATE #t SET Opening=@AA,Deactive=@AA+Active-Closing WHERE  ProductID=@MYProductID AND YY=@YY AND MM=@MM

					                    END
					                    ELSE
					                    BEGIN
					                    PRINT 'NOT EXISTS'
						                    UPDATE #t SET Opening=0 WHERE ProductID=@MYProductID AND YY=@YY AND MM=@MM
						                    UPDATE #t SET Deactive=Opening+Active-Closing WHERE ProductID=@MYProductID AND YY=@YY AND MM=@MM
					                    END
				    
						                    FETCH NEXT FROM ProductCursor INTO 
						                    @YY ,@MM ,@ProductID ,@ProductName ,@ProductType ,@Opening ,@Active ,@Deactive,@Closing 
					                    end
				                    CLOSE ProductCursor
				                    DEALLOCATE ProductCursor
			                    FETCH NEXT FROM ProductIDCursor INTO 
			                    @MYProductID
		                    END	

			                    CLOSE ProductIDCursor
			                    DEALLOCATE ProductIDCursor
                            
                                                                       
                                                                        		
		                SELECT 	ProgramLog.CAProgramID,ProgramName,BroadcasterName,CASE WHEN TTT.ProductID IS NULL  
		                    THEN 0 ELSE [Opening]  END AS [Opening],TT.[Active],TT.[Deactive], TT.ProductID,TT.ProductName,prd.CAProductID,prd.ProductType FROM #t AS TT
		                INNER JOIN  [ProductLog] Prd ON  Prd.ProductID=TT.ProductID
		                INNER JOIN 
		                (
				                    SELECT ProductID,MAX(ID)ID FROM  [ProductLog]
					                    WHERE CreateTime<=@MYDTSel			                         
					                GROUP BY ProductID
					                ) AS T
		                ON Prd.ID=T.ID
		                INNER JOIN [ProductProgramRelationLog] PPR ON PPR.ProductLogID=Prd.ID
		                INNER JOIN ( SELECT ProgramID,MAX(ID)ID FROM  ProgramLog
					                    WHERE
					                    CreateTime<=@MYDTSel			                         
					                GROUP BY ProgramID
		                ) AS  prg ON prg.ProgramID=ppr.ProgramID
		                INNER JOIN ProgramLog ON ProgramLog.ID=prg.ID
		                INNER JOIN BroadcasterInfo ON BroadcasterInfo.ID=ProgramLog.BroadcasterID
		                LEFT JOIN 
		                    (
									                    SELECT ProductID,prg.ProgramID FROM 
									                    (
									                    SELECT ProductID,MAX(ID)ID FROM  [ProductLog]
									                    WHERE CreateTime<CONVERT(nvarchar(50),@Year)+RIGHT('00'+CONVERT(nvarchar(50),@Month),2)+'01'			                         
									                GROUP BY ProductID
									                ) AS lastprd
									                INNER JOIN [ProductProgramRelationLog] PPR ON PPR.ProductLogID=lastprd.ID
									                INNER JOIN ( SELECT ProgramID,MAX(ID)ID FROM  ProgramLog
													                    WHERE
														                CreateTime<CONVERT(nvarchar(50),@Year)+RIGHT('00'+CONVERT(nvarchar(50),@Month),2)+'01'			                         
													                GROUP BY ProgramID
										                ) AS  prg ON prg.ProgramID=ppr.ProgramID
					                ) AS TTT ON TTT.ProductID=prd.ProductID AND TTT.ProgramID=prg.ProgramID
		
		                WHERE ProgramLog.BroadcasterID=@BroadcasterID  AND YY=@Year AND MM=@Month
                drop table #t 
                                                                        END
                                                                 
GO
/****** Object:  StoredProcedure [dbo].[MonthlySubsReportTotal]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

                                                                CREATE PROCEDURE [dbo].[MonthlySubsReportTotal] @Year INT,@Month INT,@BroadcasterID INT
                                                                    AS
                                                                    BEGIN
                                                                    
                    create table #t
                    (
                    YY int,
                    MM int,
                    ProductID int,
                    ProductName  NVARCHAR(50),
                    BroadcasterID int,
                    Opening int,
                    Active int,
                    Deactive int,
                    Closing int,
                    ProductType int,
                    )

                    DECLARE @DTBegin datetime;
                    SET @DTBegin=(SELECT MIN(CreateTime) FROM OrderProduct)
                                  DECLARE @MyYY INT ,@MyMM INT
			                      SET @MyYY=YEAR(@DTBegin);
			                      SET @MyMM=MONTH(@DTBegin);    
			                     DECLARE @MYDT NVARCHAR(50)
			                      SET @MYDT=CONVERT(nvarchar(10),@MyYY)+RIGHT('00'+CONVERT(nvarchar(10),@MyMM),2)+'01' 
			                                PRINT '------'+@MYDT+'--------'
			                      SET @DTBegin=CONVERT(DATETIME,@MYDT);
			                      DECLARE @TODAY DATETIME
			                      SET @TODAY=GETDATE();
                                    DECLARE @MYDTSel DATETIME--选择月的月末
			                       SET @MYDTSel=DATEADD(MONTH,1, CONVERT(nvarchar(10),@Year)+RIGHT('00'+CONVERT(nvarchar(10),@Month),2)+'01')
			                      IF (@Year=YEAR(@TODAY) AND @Month=MONTH(@TODAY))
			                       BEGIN
			                          SET @MYDTSel=GETDATE();
			                       END
                               WHILE @DTBegin<=@TODAY
                               BEGIN

                                  SET @MyYY=YEAR(@DTBegin);
			                      SET @MyMM=MONTH(@DTBegin);    
			                      SET @MYDT=CONVERT(nvarchar(10),@MyYY)+RIGHT('00'+CONVERT(nvarchar(10),@MyMM),2)+'01' 
			                                PRINT '------'+@MYDT+'--------'
			                       DECLARE @MYDT1 DATETIME--月初
			                       SET @MYDT1=CONVERT(DATETIME, @MYDT)
			                       DECLARE @MYDT2 DATETIME--月末
			                       SET @MYDT2=DATEADD(MONTH,1, @MYDT1)
                                    IF (@MyYY=YEAR(@TODAY) AND @MyMM=MONTH(@TODAY))
			                       BEGIN
			                          SET @MYDT2=GETDATE();
			                       END
			                        PRINT '-------@MYDT2------'
							                    insert into #t(YY,MM,ProductID,ProductName,ProductType,Opening,Active,Deactive,Closing)
							                    SELECT DISTINCT YY,MM,T.ProductID,ProductName,ProductType,0 as Opening,isnull([Actived],0) as [Actived],0 AS Deactive,isnull([Colosing],0) as [Colosing] FROM
                                                (
                                                  SELECT YY,MM,ProductID,0 AS BroadcasterID,0 AS Opening,[Actived],[Colosing]
                                                  FROM
                                                  (
								                    SELECT YY,MM,ProductID,CustCNT,OrderStatus FROM
								                    (
									                    SELECT YY,MM,P.ProductID,COUNT(DISTINCT [ICTableID])CustCNT,'Colosing' as OrderStatus from
										                      (
											                     SELECT * FROM
											                     (
                                                                    SELECT OP.[ID],[UserCostID],OP.[CustomerID]
                                                                  ,[ICTableID],[ProductID],[OrderFeePackageID],[PriceID],[Price],[PreferentialID],[Preferential],[OriginalFee],[RealFee]
                                                                  ,[OrderMonth],[AdjustDays],[OperateType],[RenewOriginateType],OP.[Status],[BackOrderID],OP.[Remark] ,OP.[Creator],OP.[CreateTime],OP.[LastEditor]
                                                                  ,OP.[LastEditTime],[StartDate],[EndDate],AuthTime  as [MyStartDate],UnauthTime as MyEndDate FROM OrderProduct OP
                                                                   INNER JOIN  ICCardInfo AS IC ON OP.ICTableID=IC.ID
                                                                    WHERE NOT EXISTS(SELECT ICInternalNumber FROM ICBlacklist ICB WHERE ICB.ICInternalNumber=IC.InternalNumber) AND OperateType=5  AND OP.LastEditTime<=EndDate
											                       ) AS OP
									                    WHERE   op.MyStartDate <@MYDT2
									                    AND op.MyEndDate >= @MYDT2
									                    ) AS T
									                    RIGHT  JOIN (
										                        SELECT DISTINCT @MyYY AS YY,@MyMM AS MM,Prd.ProductID,Prd.CAProductID FROM [ProductLog] Prd
											                    INNER JOIN 
											                    (
													                       SELECT CAProductID,MAX(ID)ID FROM  [ProductLog]
														                     WHERE CreateTime<=@MYDT2			                         
														                    GROUP BY CAProductID
														                    ) AS T
											                    ON Prd.ID=T.ID
											                    INNER JOIN [ProductProgramRelationLog] PPR ON PPR.ProductLogID=Prd.ID
											                    INNER JOIN ( SELECT ProgramID,MAX(ID)ID FROM  ProgramLog
														                       WHERE 
														                        CreateTime<=@MYDT2			                         
														                    GROUP BY ProgramID
											                    ) AS  prg ON prg.ProgramID=ppr.ProgramID
											                    INNER JOIN ProgramLog ON ProgramLog.ID=prg.ID
											                    WHERE ProgramLog.BroadcasterID=@BroadcasterID
									                    ) AS P ON P.ProductID=T.ProductID
									                    group by YY,MM,P.ProductID
    
								                    ) AS T1
								                    UNION 
								                    SELECT YY,MM,ProductID,CustCNT,OrderStatus FROM
								                    (
								
                                      
								
									                    SELECT YY,MM,P.ProductID,COUNT(DISTINCT [ICTableID])CustCNT,'Actived' as OrderStatus from
										                      (
											                     SELECT * FROM
											                     (
                                                                    SELECT OP.[ID],[UserCostID],OP.[CustomerID]
                                                                  ,[ICTableID],[ProductID],[OrderFeePackageID],[PriceID],[Price],[PreferentialID],[Preferential],[OriginalFee],[RealFee]
                                                                  ,[OrderMonth],[AdjustDays],[OperateType],[RenewOriginateType],OP.[Status],[BackOrderID],OP.[Remark] ,OP.[Creator],OP.[CreateTime],OP.[LastEditor]
                                                                  ,OP.[LastEditTime],[StartDate],[EndDate],AuthTime  as [MyStartDate],UnauthTime as MyEndDate FROM OrderProduct OP
                                                                   INNER JOIN  ICCardInfo AS IC ON OP.ICTableID=IC.ID
                                                                    WHERE NOT EXISTS(SELECT ICInternalNumber FROM ICBlacklist ICB WHERE ICB.ICInternalNumber=IC.InternalNumber) AND OperateType=5  AND OP.LastEditTime<=EndDate

											                       ) AS OP
									                    WHERE   YEAR(op.MyStartDate)=@MyYY AND MONTH(op.MyStartDate)=@MyMM
									                    ) AS T
									                    RIGHT  JOIN (
										                        SELECT DISTINCT @MyYY AS YY,@MyMM AS MM,Prd.ProductID,Prd.CAProductID FROM [ProductLog] Prd
											                    INNER JOIN 
											                    (
													                       SELECT CAProductID,MAX(ID)ID FROM  [ProductLog]
														                     WHERE CreateTime<=@MYDT2			                         
														                    GROUP BY CAProductID
														                    ) AS T
											                    ON Prd.ID=T.ID
											                    INNER JOIN [ProductProgramRelationLog] PPR ON PPR.ProductLogID=Prd.ID
											                    INNER JOIN ( SELECT ProgramID,MAX(ID)ID FROM  ProgramLog
														                       WHERE 
														                        CreateTime<=@MYDT2			                         
														                    GROUP BY ProgramID
											                    ) AS  prg ON prg.ProgramID=ppr.ProgramID
											                    INNER JOIN ProgramLog ON ProgramLog.ID=prg.ID
											                    WHERE ProgramLog.BroadcasterID=@BroadcasterID
									                    ) AS P ON P.ProductID=T.ProductID
									                    group by YY,MM,P.ProductID
    
								                    ) AS T1
						                       ) AS P
							                    PIVOT
							                    (
							                     SUM(CustCNT)
							                     FOR OrderStatus in([Actived],[Colosing])
							                    )AS PVT

							                    ) AS T
							                    INNER JOIN ProductInfo ON ProductInfo.ProductID=T.ProductID
                                                WHERE (Opening+[Actived]+[Colosing])>0
                            SET @DTBegin=DATEADD(MONTH,1,@DTBegin)                    
		                    END
	
		                    --truncate table #t
		                    --更新数据OPENING
		                    --先找到全部产品
		                    DECLARE @MYProductID INT
		                    DECLARE ProductIDCursor CURSOR FOR 
		                    select DISTINCT ProductID  from #t

		                    OPEN ProductIDCursor;
		                    FETCH NEXT FROM ProductIDCursor INTO 
		                    @MYProductID
		                    WHILE @@FETCH_STATUS = 0
			                    BEGIN
			                        DECLARE @YY INT,@MM INT,@ProductID INT,@ProductName nvarchar(50),@ProductType INT,@Opening INT,@Active INT,@Deactive INT,@Closing INT
				                    DECLARE ProductCursor CURSOR FOR 
				                    select YY,MM,ProductID,ProductName,ProductType,0 as Opening,Active,Deactive,Closing from #t
				                    WHERE ProductID=@MYProductID
				                    ORDER BY YY,MM
				                    OPEN ProductCursor;
				                    FETCH NEXT FROM ProductCursor INTO 
				                    @YY ,@MM ,@ProductID ,@ProductName,@ProductType ,@Opening ,@Active ,@Deactive,@Closing 
				                    WHILE @@FETCH_STATUS = 0
					                    begin
					                    DECLARE @DT DATETIME
					                    SET @DT=CONVERT(nvarchar(50),@YY)+RIGHT('00'+CONVERT(nvarchar(50),@MM),2)+'01'
					                    PRINT 'DT:'+ CONVERT(nvarchar(50),@DT,120)
					                    IF  EXISTS(     SELECT TOP 1 * FROM #t WHERE ProductID=@MYProductID AND CONVERT(DATETIME,CONVERT(nvarchar(50),YY)+RIGHT('00'+CONVERT(nvarchar(50),MM),2)+'01')<@DT
					                    ORDER BY YY DESC,MM DESC)
					                    BEGIN
					                      PRINT ' EXISTS'
					                      PRINT 'begin---------'
					                    PRINT CONVERT(NVARCHAR(50),@YY) +' '+CONVERT(NVARCHAR(50),@MM)  +' '+CONVERT(NVARCHAR(50),@ProductID) +' '+CONVERT(NVARCHAR(50),@ProductName) +' '+CONVERT(NVARCHAR(50),@ProductType) +' '+CONVERT(NVARCHAR(50),@Opening)  +' '+CONVERT(NVARCHAR(50),@Active) +' '+CONVERT(NVARCHAR(50),@Deactive )

					                     PRINT 'end---------'
					                      DECLARE @AA INT
					                      SET @AA=(SELECT TOP 1 Closing FROM #t WHERE ProductID=@MYProductID AND CONVERT(DATETIME,CONVERT(nvarchar(50),YY)+RIGHT('00'+CONVERT(nvarchar(50),MM),2)+'01')<@DT
						                    ORDER BY YY DESC,MM DESC)
						                    PRINT 'last Opening @AA'
					                      PRINT @AA
					                      --PRINT 'CLOSING'
					                      --PRINT Closing
					                      UPDATE #t SET Opening=@AA,Deactive=@AA+Active-Closing WHERE  ProductID=@MYProductID AND YY=@YY AND MM=@MM

					                    END
					                    ELSE
					                    BEGIN
					                    PRINT 'NOT EXISTS'
						                    UPDATE #t SET Opening=0 WHERE ProductID=@MYProductID AND YY=@YY AND MM=@MM
						                    UPDATE #t SET Deactive=Opening+Active-Closing WHERE ProductID=@MYProductID AND YY=@YY AND MM=@MM
					                    END
				    
						                    FETCH NEXT FROM ProductCursor INTO 
						                    @YY ,@MM ,@ProductID ,@ProductName ,@ProductType ,@Opening ,@Active ,@Deactive,@Closing 
					                    end
				                    CLOSE ProductCursor
				                    DEALLOCATE ProductCursor
			                    FETCH NEXT FROM ProductIDCursor INTO 
			                    @MYProductID
		                    END	

			                    CLOSE ProductIDCursor
			                    DEALLOCATE ProductIDCursor
                            
                                                                    
                                                                    		
                                                		            SELECT 	#t.ProductID,#t.ProductName,#t.ProductType,[Opening],#t.[Active],[Deactive],Closing,YY,MM,CAProductID FROM #t
                                                                    INNER JOIN ProductInfo ON ProductInfo.ProductID=#t.ProductID
		                                                            WHERE YY=@Year AND MM=@Month
		                                                            drop table #t 
                                                                   END
                                                                
GO
/****** Object:  Table [dbo].[AddressRegion]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AddressRegion](
	[RegionID] [bigint] IDENTITY(1,1) NOT NULL,
	[RegionName] [nvarchar](64) NOT NULL,
	[ParentRegionID] [bigint] NULL,
	[Layer] [nchar](16) NOT NULL,
	[Active] [bit] NOT NULL,
	[Creator] [nvarchar](50) NOT NULL,
	[CreateTime] [datetime] NOT NULL,
	[LastEditor] [nvarchar](50) NOT NULL,
	[LastEditTime] [datetime] NOT NULL,
 CONSTRAINT [PK_AddressRegion] PRIMARY KEY CLUSTERED 
(
	[RegionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[AuthInfo]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AuthInfo](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[ICTableID] [bigint] NULL,
	[ProductID] [bigint] NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NOT NULL,
	[OrderProductID] [bigint] NOT NULL,
 CONSTRAINT [PK_AUTHINFO] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[AutoSubtractFee]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AutoSubtractFee](
	[ID] [bigint] NOT NULL,
	[CustomerID] [bigint] NOT NULL,
	[InternalNumber] [int] NOT NULL,
	[ProductID] [int] NOT NULL,
	[RealFee] [decimal](12, 4) NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NOT NULL,
	[Creator] [nvarchar](50) NOT NULL,
	[CreateTime] [datetime] NOT NULL,
 CONSTRAINT [PK_AUTOSUBTRACTFEE] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[BalanceRecharge]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BalanceRecharge](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[UserCostID] [bigint] NULL,
	[CustomerID] [bigint] NOT NULL,
	[Amount] [decimal](12, 4) NULL,
	[Status] [int] NOT NULL,
	[Remark] [nvarchar](max) NULL,
	[Creator] [nvarchar](50) NOT NULL,
	[CreateTime] [datetime] NOT NULL,
	[LastEditor] [nvarchar](50) NOT NULL,
	[LastEditTime] [datetime] NOT NULL,
 CONSTRAINT [PK_BALANCERECHARGE] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[BaseData]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BaseData](
	[CodeType] [nvarchar](64) NOT NULL,
	[CodeTypeName] [nvarchar](64) NOT NULL,
	[Code] [nvarchar](64) NOT NULL,
	[CodeValue] [nvarchar](64) NOT NULL,
	[Remark] [nvarchar](max) NULL,
 CONSTRAINT [PK_BaseData] PRIMARY KEY CLUSTERED 
(
	[CodeType] ASC,
	[Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[BatchBill]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BatchBill](
	[BillID] [bigint] IDENTITY(1,1) NOT NULL,
	[BatchID] [bigint] NOT NULL,
	[RealFee] [decimal](12, 4) NOT NULL,
	[ChargeCash] [decimal](12, 4) NOT NULL,
	[Department] [bigint] NOT NULL,
	[PrintCount] [int] NOT NULL,
	[Remark] [nvarchar](max) NULL,
	[Creator] [nvarchar](64) NOT NULL,
	[CreateTime] [datetime] NOT NULL,
	[BillNumber] [nvarchar](50) NULL,
 CONSTRAINT [PK_BatchBill] PRIMARY KEY CLUSTERED 
(
	[BillID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[BatchBillDetail]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BatchBillDetail](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[BatchBillID] [bigint] NULL,
	[ItemType] [int] NULL,
	[ItemQuantity] [decimal](12, 4) NULL,
 CONSTRAINT [PK_BatchBillDetail] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[BatchOrderProduct]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BatchOrderProduct](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[Remark] [nvarchar](max) NULL,
	[Creator] [nvarchar](64) NOT NULL,
	[CreateTime] [datetime] NOT NULL,
	[LastEditor] [nvarchar](64) NOT NULL,
	[LastEditTime] [datetime] NOT NULL,
 CONSTRAINT [PK_BATCHORDERPRODUCT] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[BatchOrderProductRelation]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BatchOrderProductRelation](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[BatchID] [bigint] NOT NULL,
	[UserCostID] [bigint] NOT NULL,
	[OrderID] [bigint] NULL,
 CONSTRAINT [PK_BATCHORDERPRODUCTRELATION] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[BillDetail]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BillDetail](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[BillID] [bigint] NOT NULL,
	[PriceType] [int] NOT NULL,
	[OrderID] [bigint] NOT NULL,
	[OrderFeePackageID] [bigint] NULL,
	[PackageID] [bigint] NULL,
	[PackageName] [nvarchar](128) NULL,
	[ICNumber] [nvarchar](64) NULL,
	[STBNumber] [nvarchar](64) NULL,
	[ProductID] [int] NULL,
	[ProductName] [nvarchar](64) NULL,
	[StartTime] [datetime] NULL,
	[EndTime] [datetime] NULL,
	[PriceID] [bigint] NOT NULL,
	[PreferentialID] [bigint] NULL,
	[OriginalFee] [decimal](14, 4) NOT NULL,
	[PreferentialFee] [decimal](14, 4) NOT NULL,
	[RealFee] [decimal](14, 4) NOT NULL,
	[Remark] [nvarchar](max) NULL,
	[OperateType] [int] NOT NULL,
 CONSTRAINT [PK_BILLDETAIL] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[BillInfo]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BillInfo](
	[BillID] [bigint] IDENTITY(1,1) NOT NULL,
	[BillNumber] [nvarchar](64) NULL,
	[UserCostID] [bigint] NOT NULL,
	[CustomerID] [bigint] NOT NULL,
	[CustomerNumber] [nvarchar](64) NOT NULL,
	[CustomerName] [nvarchar](64) NOT NULL,
	[CustomerType] [nvarchar](64) NOT NULL,
	[ChargeFee] [decimal](14, 4) NOT NULL,
	[ChargeCash] [decimal](12, 4) NOT NULL,
	[ChargeBalance] [decimal](12, 4) NOT NULL,
	[ChargeOther] [decimal](12, 4) NOT NULL,
	[RealFee] [decimal](14, 4) NOT NULL,
	[LastAdjust] [decimal](14, 4) NOT NULL,
	[Adjust] [decimal](14, 4) NOT NULL,
	[Remark] [nvarchar](128) NULL,
	[PrintCount] [int] NOT NULL,
	[Creator] [nvarchar](64) NOT NULL,
	[CreateTime] [datetime] NOT NULL,
 CONSTRAINT [PK_PrintHistory] PRIMARY KEY CLUSTERED 
(
	[BillID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[BroadcasterInfo]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BroadcasterInfo](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[BroadcasterName] [nvarchar](64) NOT NULL,
	[Remark] [nvarchar](max) NULL,
	[Active] [bit] NOT NULL,
	[Creator] [nvarchar](64) NOT NULL,
	[CreateTime] [datetime] NOT NULL,
	[LastEditor] [nvarchar](64) NOT NULL,
	[LastEditTime] [datetime] NOT NULL,
 CONSTRAINT [PK_BroadcasterInfo] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[CAInstance]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CAInstance](
	[ID] [int] NOT NULL,
	[Name] [nvarchar](128) NOT NULL,
	[IPAddress] [varchar](64) NOT NULL,
	[Port] [int] NOT NULL,
	[Remark] [nvarchar](256) NULL,
	[Active] [bit] NOT NULL,
	[SortSetting] [int] NOT NULL,
 CONSTRAINT [PK_CAINSTANCE] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CertificateType]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CertificateType](
	[CertificateTypeID] [int] IDENTITY(1,1) NOT NULL,
	[CertificateName] [nvarchar](64) NOT NULL,
	[Active] [bit] NOT NULL,
	[Creator] [nvarchar](64) NOT NULL,
	[CreateTime] [datetime] NOT NULL,
	[LastEditor] [nvarchar](64) NOT NULL,
	[LastEditTime] [datetime] NOT NULL,
 CONSTRAINT [PK_CERTIFICATETYPE] PRIMARY KEY CLUSTERED 
(
	[CertificateTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ChangeEquipment]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ChangeEquipment](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[CustomerID] [bigint] NOT NULL,
	[EquTypeCode] [int] NOT NULL,
	[OriginalEquID] [bigint] NOT NULL,
	[NewEquID] [bigint] NOT NULL,
	[ChangeWay] [int] NOT NULL,
	[OrderID] [bigint] NOT NULL,
	[Remark] [nvarchar](max) NULL,
	[Creator] [nvarchar](64) NOT NULL,
	[CreateTime] [datetime] NOT NULL,
	[LastEditor] [nvarchar](64) NOT NULL,
	[LastEditTime] [datetime] NOT NULL,
 CONSTRAINT [PK_ChangeEquipment] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ChangeOwner]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ChangeOwner](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[OriginalCustomerID] [bigint] NOT NULL,
	[NewCustomerID] [bigint] NOT NULL,
	[EquipmentTypeCode] [int] NOT NULL,
	[EquipmentID] [bigint] NOT NULL,
	[Remark] [nvarchar](max) NOT NULL,
	[Creator] [nvarchar](64) NOT NULL,
	[CreateTime] [datetime] NOT NULL,
	[LastEditor] [nvarchar](64) NOT NULL,
	[LastEditTime] [datetime] NOT NULL,
 CONSTRAINT [PK_OwnerChange] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ConditionAddress]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ConditionAddress](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[ConditionType] [int] NOT NULL,
	[CASVersion] [int] NOT NULL,
	[CASID] [bigint] NOT NULL,
	[OperatorName] [nvarchar](64) NOT NULL,
	[StartTime] [datetime] NOT NULL,
	[EndTime] [datetime] NOT NULL,
	[DepartmentID] [int] NOT NULL,
	[Active] [bit] NOT NULL,
	[Creator] [nvarchar](64) NOT NULL,
	[CreateTime] [datetime] NOT NULL,
	[LastEditor] [nvarchar](64) NOT NULL,
	[LastEditTime] [datetime] NOT NULL,
 CONSTRAINT [PK_CONDITIONBASE] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ConditionMail]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ConditionMail](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[ConditionID] [bigint] NOT NULL,
	[MailTitle] [nvarchar](64) NOT NULL,
	[MailContent] [nvarchar](max) NOT NULL,
	[MailSign] [nvarchar](64) NOT NULL,
	[MailPriority] [int] NOT NULL,
 CONSTRAINT [PK_CONDITIONMAIL] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ConditionOSD]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ConditionOSD](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[ConditionID] [bigint] NOT NULL,
	[OSDContent] [nvarchar](max) NOT NULL,
	[DisplayCount] [int] NOT NULL,
	[Priority] [int] NOT NULL,
	[Position] [int] NOT NULL,
	[Font_Size] [int] NOT NULL,
	[Font_Type] [int] NOT NULL,
	[Font_Color] [int] NOT NULL,
	[Background_Color] [int] NOT NULL,
 CONSTRAINT [PK_CONDITIONOSD] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ConditionWithKey]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ConditionWithKey](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[ConditionID] [bigint] NOT NULL,
	[Ordering] [int] NOT NULL,
	[IsAnd] [int] NOT NULL,
	[ConditionByType] [int] NOT NULL,
	[OperateType] [int] NOT NULL,
	[Val] [nvarchar](64) NOT NULL,
 CONSTRAINT [PK_CONDITIONWITHKEY] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ConditionWithProducts]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ConditionWithProducts](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[ConditionID] [bigint] NULL,
	[ProductID] [bigint] NOT NULL,
 CONSTRAINT [PK_CONDITIONWITHPRODUCTS] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ConditionWithPrograms]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ConditionWithPrograms](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[ConditionID] [bigint] NULL,
	[ProgramID] [bigint] NOT NULL,
 CONSTRAINT [PK_CONDITIONWITHPROGRAMS] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[CustomerInfo]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CustomerInfo](
	[CustomerID] [bigint] IDENTITY(1,1) NOT NULL,
	[CustomerNumber] [nvarchar](64) NULL,
	[CustomerName] [nvarchar](64) NOT NULL,
	[CertificateTypeID] [int] NULL,
	[CertificateID] [nvarchar](64) NULL,
	[TelNumber] [nvarchar](64) NULL,
	[MobilePhoneNumber] [nvarchar](64) NULL,
	[RegionID] [bigint] NOT NULL,
	[Address] [nvarchar](128) NULL,
	[CustTypeID] [int] NOT NULL,
	[MasterDepartmentID] [int] NOT NULL,
	[DepartmentID] [int] NOT NULL,
	[Remark] [nvarchar](max) NULL,
	[BillingAddress] [nvarchar](max) NULL,
	[EmailID] [nvarchar](max) NULL,
	[SubscriptionContractNumber] [nvarchar](64) NULL,
	[balance] [decimal](12, 4) NOT NULL,
	[Adjust] [decimal](12, 4) NOT NULL,
	[Status] [int] NOT NULL,
	[Active] [bit] NOT NULL,
	[NewAccountTime] [datetime] NULL,
	[Creator] [nvarchar](64) NOT NULL,
	[CreateTime] [datetime] NOT NULL,
	[LastEditor] [nvarchar](64) NOT NULL,
	[LastEditTime] [datetime] NOT NULL,
 CONSTRAINT [PK_CustomerInfo] PRIMARY KEY CLUSTERED 
(
	[CustomerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[CustomerInit]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CustomerInit](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[UserCostID] [bigint] NULL,
	[CustomerID] [bigint] NOT NULL,
	[OrderFeePackageID] [bigint] NULL,
	[PriceID] [bigint] NOT NULL,
	[Price] [decimal](12, 4) NOT NULL,
	[PreferentialID] [bigint] NULL,
	[Preferential] [decimal](12, 4) NOT NULL,
	[OriginalFee] [decimal](12, 4) NOT NULL,
	[RealFee] [decimal](12, 4) NOT NULL,
	[OperateType] [int] NOT NULL,
	[Status] [int] NOT NULL,
	[BackOrderID] [bigint] NULL,
	[Remark] [nvarchar](max) NULL,
	[Creator] [nvarchar](50) NOT NULL,
	[CreateTime] [datetime] NOT NULL,
	[LastEditor] [nvarchar](50) NOT NULL,
	[LastEditTime] [datetime] NOT NULL,
 CONSTRAINT [PK_CUSTOMERINIT] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[CustomerInstal]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CustomerInstal](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[UserCostID] [bigint] NULL,
	[CustomerID] [bigint] NOT NULL,
	[FeeName] [nvarchar](256) NULL,
	[RealFee] [decimal](12, 4) NOT NULL,
	[OperateType] [int] NOT NULL,
	[Status] [int] NOT NULL,
	[BackOrderID] [bigint] NULL,
	[Remark] [nvarchar](max) NULL,
	[Creator] [nvarchar](50) NOT NULL,
	[CreateTime] [datetime] NOT NULL,
	[LastEditor] [nvarchar](50) NOT NULL,
	[LastEditTime] [datetime] NOT NULL,
 CONSTRAINT [PK_CUSTOMERINSTAL] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[CustTypeInfo]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CustTypeInfo](
	[CustTypeID] [int] IDENTITY(1,1) NOT NULL,
	[CustTypeName] [nvarchar](256) NOT NULL,
	[DepartmentID] [int] NOT NULL,
	[Active] [bit] NOT NULL,
	[Creator] [nvarchar](256) NOT NULL,
	[CreateTime] [datetime] NOT NULL,
	[LastEditor] [nvarchar](256) NOT NULL,
	[LastEditTime] [datetime] NOT NULL,
 CONSTRAINT [PK_CUSTTYPEINFO] PRIMARY KEY CLUSTERED 
(
	[CustTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[DailySettleAccount]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DailySettleAccount](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[UserID] [nvarchar](64) NOT NULL,
	[CreateTime] [datetime] NOT NULL,
	[Fee] [decimal](18, 6) NOT NULL,
	[ChargeCash] [decimal](18, 6) NOT NULL,
	[Remark] [nvarchar](max) NULL,
 CONSTRAINT [PK_DailySettleAccount] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Department]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Department](
	[DepartmentID] [bigint] IDENTITY(1,1) NOT NULL,
	[DepartmentName] [nvarchar](256) NOT NULL,
	[ParentDepartmentID] [bigint] NULL,
	[DepartmentType] [int] NOT NULL,
	[Layer] [nchar](16) NOT NULL,
	[Active] [bit] NOT NULL,
	[Creator] [nvarchar](50) NOT NULL,
	[CreateTime] [datetime] NOT NULL,
	[LastEditor] [nvarchar](50) NOT NULL,
	[LastEditTime] [datetime] NOT NULL,
 CONSTRAINT [PK_DEPARTMENT] PRIMARY KEY CLUSTERED 
(
	[DepartmentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Department_Region_Relation]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Department_Region_Relation](
	[DepartmentID] [int] NOT NULL,
	[RegionID] [bigint] NOT NULL,
 CONSTRAINT [PK_DEPARTMENT_REGION_RELATION] PRIMARY KEY CLUSTERED 
(
	[RegionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[DueRemain]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DueRemain](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[CustomerID] [bigint] NOT NULL,
	[CustomerName] [nvarchar](256) NULL,
	[Tel] [nvarchar](64) NULL,
	[MsgContent] [nvarchar](512) NULL,
	[ICTableID] [bigint] NOT NULL,
	[InternalNumber] [int] NOT NULL,
	[ExternalNumber] [nvarchar](16) NULL,
	[CreateTime] [datetime] NOT NULL,
	[MaxEndDate] [datetime] NOT NULL,
	[SendTimeBefore] [datetime] NULL,
	[SendTimesBefore] [int] NOT NULL,
	[StateBefore] [bit] NOT NULL,
	[SendTimeAfter] [datetime] NULL,
	[SendTimesAfter] [int] NOT NULL,
	[StateAfter] [bit] NOT NULL,
	[IsRenew] [bit] NOT NULL,
 CONSTRAINT [PK_DUEREMAIN] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[E_Notecase]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[E_Notecase](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[UserCostID] [bigint] NULL,
	[CustomerID] [bigint] NOT NULL,
	[ICTableID] [bigint] NOT NULL,
	[OrderFeePackageID] [bigint] NULL,
	[PriceID] [bigint] NOT NULL,
	[Price] [decimal](12, 4) NOT NULL,
	[PreferentialID] [bigint] NULL,
	[Preferential] [decimal](12, 4) NOT NULL,
	[OriginalFee] [decimal](12, 4) NOT NULL,
	[RealFee] [decimal](12, 4) NOT NULL,
	[Case1] [int] NOT NULL,
	[Case2] [int] NOT NULL,
	[Case3] [int] NOT NULL,
	[Case4] [int] NOT NULL,
	[OperateType] [int] NOT NULL,
	[Status] [int] NOT NULL,
	[BackOrderID] [bigint] NULL,
	[Remark] [nvarchar](max) NULL,
	[Creator] [nvarchar](50) NOT NULL,
	[CreateTime] [datetime] NOT NULL,
	[LastEditor] [nvarchar](50) NOT NULL,
	[LastEditTime] [datetime] NOT NULL,
 CONSTRAINT [PK_E_Notecase] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[EasyPayBusinessInfo]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EasyPayBusinessInfo](
	[BusinessID] [nvarchar](50) NOT NULL,
	[OrgID] [bigint] NOT NULL,
	[IsReverse] [bit] NOT NULL,
	[Creator] [nvarchar](64) NOT NULL,
	[CreateTime] [datetime] NOT NULL,
	[LastEditor] [nvarchar](64) NOT NULL,
	[LastEditTime] [datetime] NOT NULL,
	[EPDayCheckID] [int] NULL,
 CONSTRAINT [PK_BusinessInfo] PRIMARY KEY CLUSTERED 
(
	[BusinessID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[EasyPayBusinessOrder]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EasyPayBusinessOrder](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[BusinessID] [nvarchar](50) NULL,
	[OrderProductID] [bigint] NULL,
 CONSTRAINT [PK_EasyPayBusinessOrder] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[EasyPayDayCheck]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EasyPayDayCheck](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[OrgID] [bigint] NOT NULL,
	[CheckDate] [datetime] NOT NULL,
	[TotalCount] [int] NOT NULL,
	[TotalAmount] [decimal](12, 6) NOT NULL,
	[Creator] [nvarchar](64) NOT NULL,
	[CreateTime] [datetime] NOT NULL,
	[SMSTotalAmount] [decimal](12, 6) NULL,
	[SMSTotalCount] [int] NULL,
	[EPCheckState] [int] NULL,
 CONSTRAINT [PK_EasyPayDayCheck] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[EasyPayInfo]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EasyPayInfo](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[BusinessID] [nvarchar](50) NULL,
	[UserCostID] [bigint] NOT NULL,
	[CustomerID] [bigint] NOT NULL,
	[ICTableID] [bigint] NOT NULL,
	[InternalNumber] [bigint] NOT NULL,
	[RechargeNumber] [nvarchar](64) NULL,
	[Tel] [nvarchar](64) NULL,
	[CreateDate] [datetime] NOT NULL,
	[Cash] [int] NULL,
	[UseCash] [decimal](12, 6) NULL,
	[Balance] [decimal](12, 6) NULL,
	[RechargeTypes] [int] NULL,
	[State] [bit] NOT NULL,
	[Remark] [nvarchar](max) NULL,
 CONSTRAINT [PK_EASYPAYINFO] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[EasyPayOrg]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EasyPayOrg](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[OrgCode] [nvarchar](50) NULL,
	[OrgName] [nvarchar](50) NULL,
	[OrgKey] [nvarchar](50) NULL,
	[Active] [bit] NOT NULL,
	[Creator] [nvarchar](64) NOT NULL,
	[CreateTime] [datetime] NOT NULL,
	[LastEditor] [nvarchar](64) NOT NULL,
	[LastEditTime] [datetime] NOT NULL,
 CONSTRAINT [PK_EasyPayOrg] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ECMGFinger]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ECMGFinger](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[ConditionID] [bigint] NOT NULL,
	[IsForce] [bit] NOT NULL,
 CONSTRAINT [PK_ECMGFINGER] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[EmergencyBroadcast]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EmergencyBroadcast](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[ProgramID] [bigint] NOT NULL,
	[Active] [bit] NOT NULL,
	[Creator] [nvarchar](50) NOT NULL,
	[CreateTime] [datetime] NOT NULL,
 CONSTRAINT [PK_EmergencyBroadcast] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[EMMGFinger]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EMMGFinger](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[ConditionID] [bigint] NOT NULL,
	[ShowTime] [int] NOT NULL,
	[StopTime] [int] NOT NULL,
	[Font_Size] [int] NOT NULL,
	[Font_Type] [int] NOT NULL,
	[ColorType] [int] NOT NULL,
	[Font_Color] [int] NOT NULL,
	[Background_Color] [int] NOT NULL,
	[Positions] [int] NOT NULL,
	[PositionX] [int] NOT NULL,
	[PositionY] [int] NOT NULL,
	[OvertFlag] [bit] NOT NULL,
	[IsDisplayBackGround] [bit] NOT NULL,
	[IsDisplaySTBID] [bit] NOT NULL,
 CONSTRAINT [PK_EMMGFINGER] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[FeePackage]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FeePackage](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[PackageName] [nvarchar](128) NOT NULL,
	[DepartmentID] [int] NOT NULL,
	[CustTypeID] [int] NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NOT NULL,
	[OriginalFee] [decimal](12, 4) NULL,
	[RealFee] [decimal](12, 4) NOT NULL,
	[Balance] [decimal](12, 4) NOT NULL,
	[FeeModel] [int] NOT NULL,
	[Status] [int] NOT NULL,
	[Active] [bit] NOT NULL,
	[Remark] [nvarchar](max) NULL,
	[Creator] [nvarchar](64) NOT NULL,
	[CreateTime] [datetime] NOT NULL,
	[LastEditor] [nvarchar](64) NOT NULL,
	[LastEditTime] [datetime] NOT NULL,
	[PackageType] [int] NULL,
 CONSTRAINT [PK_FEEPACKAGE] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[FeePackageEquipment]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FeePackageEquipment](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[PackageID] [bigint] NOT NULL,
	[ModelNumber] [int] NOT NULL,
	[Quantity] [int] NOT NULL,
	[OriginalFee] [decimal](12, 4) NOT NULL,
	[RealFee] [decimal](12, 4) NOT NULL,
 CONSTRAINT [PK_FEEPACKAGEEQUIPMENT] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[FeePackageOther]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FeePackageOther](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[PackageID] [bigint] NOT NULL,
	[PriceType] [int] NOT NULL,
	[OriginalFee] [decimal](12, 4) NOT NULL,
	[RealFee] [decimal](12, 4) NOT NULL,
 CONSTRAINT [PK_FEEPACKAGEOTHER] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[FeePackageProduct]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FeePackageProduct](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[PackageID] [bigint] NOT NULL,
	[ProductID] [int] NOT NULL,
	[Quantity] [int] NOT NULL,
	[OriginalFee] [decimal](12, 4) NOT NULL,
	[RealFee] [decimal](12, 4) NOT NULL,
	[Unit] [int] NULL,
 CONSTRAINT [PK_FEEPACKAGEPRODUCT] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ForceOSD]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ForceOSD](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[ConditionID] [bigint] NOT NULL,
	[Font_Size] [int] NOT NULL,
	[Font_Type] [int] NOT NULL,
	[ColorType] [int] NOT NULL,
	[Font_Color] [int] NOT NULL,
	[Background_Color] [int] NOT NULL,
	[OSDContent] [nvarchar](max) NOT NULL,
	[Ratio] [int] NOT NULL,
	[ShowTime] [int] NOT NULL,
	[StopTime] [int] NOT NULL,
	[Clarity] [int] NOT NULL,
	[IsForceOSD] [bit] NOT NULL,
 CONSTRAINT [PK_FORCEOSD] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Function_Permit_Relation]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Function_Permit_Relation](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FunctionID] [int] NOT NULL,
	[PermitID] [int] NOT NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[GroupInfo]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[GroupInfo](
	[GroupID] [int] IDENTITY(1,1) NOT NULL,
	[GroupName] [nvarchar](64) NOT NULL,
	[DepartmentID] [bigint] NOT NULL,
	[Status] [bit] NOT NULL,
	[Creator] [nvarchar](50) NOT NULL,
	[CreateTime] [datetime] NOT NULL,
	[LastEditor] [nvarchar](50) NOT NULL,
	[LastEditTime] [datetime] NOT NULL,
	[IsPublic] [bit] NOT NULL,
 CONSTRAINT [PK__GroupInfo__267ABA7A] PRIMARY KEY CLUSTERED 
(
	[GroupID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ICBlacklist]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ICBlacklist](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[ICTableID] [bigint] NOT NULL,
	[Remark] [nvarchar](max) NULL,
	[ICInternalNumber] [int] NOT NULL,
	[Creator] [nvarchar](64) NOT NULL,
	[CreateTime] [datetime] NOT NULL,
	[LastEditor] [nvarchar](64) NOT NULL,
	[LastEditTime] [datetime] NOT NULL,
 CONSTRAINT [PK_ICBlacklist] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ICCardGroup]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ICCardGroup](
	[GroupID] [int] IDENTITY(1,1) NOT NULL,
	[GroupName] [nvarchar](64) NOT NULL,
	[DepartmentID] [int] NOT NULL,
	[Status] [bit] NOT NULL,
	[Creator] [nvarchar](50) NOT NULL,
	[CreateTime] [datetime] NOT NULL,
	[LastEditor] [nvarchar](50) NOT NULL,
	[LastEditTime] [datetime] NOT NULL,
 CONSTRAINT [PK_ICCARDGROUP] PRIMARY KEY CLUSTERED 
(
	[GroupID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ICCardInfo]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ICCardInfo](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[InternalNumber] [int] NOT NULL,
	[ExternalNumber] [nvarchar](64) NOT NULL,
	[ParentICTableID] [bigint] NULL,
	[MatchFlag] [bit] NOT NULL,
	[Priority] [int] NOT NULL,
	[UnlockVersion] [int] NOT NULL,
	[CustomerID] [bigint] NULL,
	[ModelNumber] [int] NOT NULL,
	[RegionID] [bigint] NULL,
	[DepartmentID] [int] NULL,
	[CurrentFeeModel] [int] NOT NULL,
	[NextFeeModel] [int] NOT NULL,
	[Status] [int] NOT NULL,
	[GroupID] [int] NULL,
	[Active] [bit] NOT NULL,
	[Creator] [nvarchar](64) NOT NULL,
	[CreateTime] [datetime] NOT NULL,
	[LastEditor] [nvarchar](64) NOT NULL,
	[LastEditTime] [datetime] NOT NULL,
	[FingerPrint] [bit] NOT NULL,
	[AreaLock] [bit] NOT NULL,
 CONSTRAINT [PK_ICCardInfo] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ICStatusChange]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ICStatusChange](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[ICTableID] [bigint] NULL,
	[InternalNumber] [int] NULL,
	[STBID] [bigint] NULL,
	[STBRealNumber] [nvarchar](64) NULL,
	[ICStatus] [int] NULL,
	[CustomerID] [bigint] NULL,
	[DepartmentID] [int] NULL,
	[Creator] [nvarchar](64) NULL,
	[CreateTime] [datetime] NULL,
	[Remark] [nvarchar](max) NULL,
 CONSTRAINT [PK_ICStatusChange] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ICSTBPairing]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ICSTBPairing](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[ICTableID] [bigint] NOT NULL,
	[STBTableID] [bigint] NOT NULL,
 CONSTRAINT [PK_ICSTBPAIRING] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[LogInfoManagement]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LogInfoManagement](
	[LogID] [bigint] IDENTITY(1,1) NOT NULL,
	[UserID] [nvarchar](64) NOT NULL,
	[UserName] [nvarchar](64) NOT NULL,
	[FunctionID] [nvarchar](64) NULL,
	[EventType] [int] NOT NULL,
	[ICTableID] [bigint] NULL,
	[Description] [nvarchar](max) NOT NULL,
	[OperateDateTime] [datetime] NOT NULL,
	[IPAddress] [nvarchar](64) NOT NULL,
	[ConditionalAddrID] [bigint] NULL,
 CONSTRAINT [PK_LOGINFOMANAGEMENT] PRIMARY KEY CLUSTERED 
(
	[LogID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[MailInfo]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MailInfo](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[CASVersion] [int] NOT NULL,
	[CAEveintID] [bigint] NOT NULL,
	[BeginCardID] [bigint] NOT NULL,
	[EndCardID] [bigint] NOT NULL,
	[RegionID] [bigint] NULL,
	[MailTitle] [nvarchar](64) NOT NULL,
	[MailContext] [nvarchar](1500) NOT NULL,
	[Priority] [int] NOT NULL,
	[MailSign] [nvarchar](20) NOT NULL,
	[BeginDateTime] [datetime] NOT NULL,
	[EndDateTime] [datetime] NOT NULL,
	[MailFee] [decimal](18, 6) NULL,
	[ContentProvider] [nvarchar](64) NULL,
	[DepartmentID] [int] NOT NULL,
	[Active] [bit] NOT NULL,
	[Creator] [nvarchar](50) NOT NULL,
	[CreateTime] [datetime] NOT NULL,
	[LastEditor] [nvarchar](50) NOT NULL,
	[LastEditTime] [datetime] NOT NULL,
 CONSTRAINT [PK_MAILINFO] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[NoAuthorizeWatchTime]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NoAuthorizeWatchTime](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[StartTime] [datetime] NOT NULL,
	[EndTime] [datetime] NOT NULL,
	[WatchTime] [int] NOT NULL,
	[Active] [bit] NOT NULL,
	[Creator] [nvarchar](50) NOT NULL,
	[CreateTime] [datetime] NOT NULL,
	[LastEditor] [nvarchar](50) NOT NULL,
	[LastEditTime] [datetime] NOT NULL,
	[DepartmentID] [bigint] NOT NULL,
 CONSTRAINT [PK_NOAUTHORIZEWATCHTIME] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[NoAuthWatchProgramRelation]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NoAuthWatchProgramRelation](
	[ID] [bigint] NOT NULL,
	[ProgramID] [int] NOT NULL,
 CONSTRAINT [PK_NOAUTHWATCHPROGRAMRELATION] PRIMARY KEY CLUSTERED 
(
	[ID] ASC,
	[ProgramID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[OrderCard]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OrderCard](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[UserCostID] [bigint] NULL,
	[CustomerID] [bigint] NOT NULL,
	[ICTableID] [bigint] NOT NULL,
	[OrderFeePackageID] [bigint] NULL,
	[PriceID] [bigint] NOT NULL,
	[Price] [decimal](12, 4) NOT NULL,
	[PreferentialID] [bigint] NULL,
	[Preferential] [decimal](12, 4) NOT NULL,
	[OriginalFee] [decimal](12, 4) NOT NULL,
	[RealFee] [decimal](12, 4) NOT NULL,
	[OperateType] [int] NOT NULL,
	[Status] [int] NOT NULL,
	[BackOrderID] [bigint] NULL,
	[Remark] [nvarchar](max) NULL,
	[Creator] [nvarchar](50) NOT NULL,
	[CreateTime] [datetime] NOT NULL,
	[LastEditor] [nvarchar](50) NOT NULL,
	[LastEditTime] [datetime] NOT NULL,
 CONSTRAINT [PK_OrderCard] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[OrderFeePackage]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OrderFeePackage](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[UserCostID] [bigint] NULL,
	[CustomerID] [bigint] NOT NULL,
	[FeePackageID] [bigint] NOT NULL,
	[OriginalFee] [decimal](12, 4) NOT NULL,
	[RealFee] [decimal](12, 4) NOT NULL,
	[OperateType] [int] NOT NULL,
	[Status] [int] NOT NULL,
	[BackOrderID] [bigint] NULL,
	[Remark] [nvarchar](max) NULL,
	[Creator] [nvarchar](50) NOT NULL,
	[CreateTime] [datetime] NOT NULL,
	[LastEditor] [nvarchar](50) NOT NULL,
	[LastEditTime] [datetime] NOT NULL,
 CONSTRAINT [PK_ORDERFEEPACKAGE] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[OrderPrestore]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OrderPrestore](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[UserCostID] [bigint] NULL,
	[CustomerID] [bigint] NOT NULL,
	[ICTableID] [bigint] NOT NULL,
	[ProductID] [int] NULL,
	[OrderFeePackageID] [bigint] NULL,
	[PriceID] [bigint] NOT NULL,
	[Price] [decimal](12, 4) NOT NULL,
	[PreferentialID] [bigint] NULL,
	[Preferential] [decimal](12, 4) NOT NULL,
	[OriginalFee] [decimal](12, 4) NOT NULL,
	[RealFee] [decimal](12, 4) NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NOT NULL,
	[Status] [int] NOT NULL,
	[IsUseSignPrice] [bit] NOT NULL,
	[Remark] [nvarchar](max) NULL,
	[Creator] [nvarchar](64) NOT NULL,
	[CreateTime] [datetime] NOT NULL,
	[LastEditor] [nvarchar](64) NOT NULL,
	[LastEditTime] [datetime] NOT NULL,
	[OperateType] [int] NULL,
	[RenewOriginateType] [int] NOT NULL,
 CONSTRAINT [PK_CONTRACTINFO] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[OrderProduct]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OrderProduct](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[UserCostID] [bigint] NULL,
	[CustomerID] [bigint] NOT NULL,
	[ICTableID] [bigint] NOT NULL,
	[ProductID] [int] NOT NULL,
	[OrderFeePackageID] [bigint] NULL,
	[PriceID] [bigint] NOT NULL,
	[Price] [decimal](12, 4) NOT NULL,
	[PreferentialID] [bigint] NULL,
	[Preferential] [decimal](12, 4) NOT NULL,
	[OriginalFee] [decimal](12, 4) NOT NULL,
	[RealFee] [decimal](12, 4) NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NOT NULL,
	[OrderMonth] [int] NOT NULL,
	[AdjustDays] [int] NOT NULL,
	[OperateType] [int] NOT NULL,
	[RenewOriginateType] [int] NOT NULL,
	[Status] [int] NOT NULL,
	[BackOrderID] [bigint] NULL,
	[Remark] [nvarchar](max) NULL,
	[Creator] [nvarchar](50) NOT NULL,
	[CreateTime] [datetime] NOT NULL,
	[LastEditor] [nvarchar](50) NOT NULL,
	[LastEditTime] [datetime] NOT NULL,
	[AuthTime] [datetime] NULL,
	[UnAuthTime] [datetime] NULL,
	[AuthStatus] [int] NULL,
	[ReferOrderID] [bigint] NULL,
 CONSTRAINT [PK_OrderProduct] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[OrderProductPlan]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OrderProductPlan](
	[InternalNumber] [bigint] NOT NULL,
	[ProductID] [int] NOT NULL,
	[NextDeductDate] [datetime] NOT NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[OrderSTB]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OrderSTB](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[UserCostID] [bigint] NULL,
	[CustomerID] [bigint] NOT NULL,
	[STBID] [bigint] NOT NULL,
	[OrderFeePackageID] [bigint] NULL,
	[PriceID] [bigint] NOT NULL,
	[Price] [decimal](12, 4) NOT NULL,
	[PreferentialID] [bigint] NULL,
	[Preferential] [decimal](12, 4) NOT NULL,
	[OriginalFee] [decimal](12, 4) NOT NULL,
	[RealFee] [decimal](12, 4) NOT NULL,
	[OperateType] [int] NOT NULL,
	[Status] [int] NOT NULL,
	[BackOrderID] [bigint] NULL,
	[Remark] [nvarchar](max) NULL,
	[Creator] [nvarchar](50) NOT NULL,
	[CreateTime] [datetime] NOT NULL,
	[LastEditor] [nvarchar](50) NOT NULL,
	[LastEditTime] [datetime] NOT NULL,
 CONSTRAINT [PK_OrderSTB] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[OSDInfo]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OSDInfo](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[CASVersion] [int] NULL,
	[CAEveintID] [bigint] NULL,
	[BeginCardID] [bigint] NULL,
	[EndCardID] [bigint] NULL,
	[RegionID] [bigint] NULL,
	[ProductID] [int] NULL,
	[OSDContent] [nvarchar](max) NOT NULL,
	[Priority] [int] NULL,
	[SendCount] [int] NOT NULL,
	[BeginDateTime] [datetime] NOT NULL,
	[EndDateTime] [datetime] NOT NULL,
	[OSDFee] [decimal](12, 4) NULL,
	[ContentProvider] [nvarchar](128) NOT NULL,
	[Operator] [nvarchar](64) NULL,
	[OperateDateTime] [datetime] NOT NULL,
	[Position] [int] NULL,
	[FountSize] [int] NULL,
	[FountType] [int] NULL,
	[FountColor] [int] NULL,
	[BackgroundColor] [int] NULL,
	[DepartmentID] [int] NOT NULL,
	[Active] [bit] NOT NULL,
	[Creator] [nvarchar](64) NOT NULL,
	[CreateTime] [datetime] NOT NULL,
	[LastEditor] [nvarchar](64) NOT NULL,
	[LastEditTime] [datetime] NULL,
 CONSTRAINT [PK_OSDINFO] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Permit]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Permit](
	[PermitID] [int] NOT NULL,
	[PermitName] [nvarchar](64) NOT NULL,
 CONSTRAINT [PK_PERMIT] PRIMARY KEY CLUSTERED 
(
	[PermitID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[PermitGroupSetting]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PermitGroupSetting](
	[GroupID] [int] NOT NULL,
	[PermitRelationID] [int] NOT NULL,
 CONSTRAINT [PK_PERMITGROUPSETTING] PRIMARY KEY CLUSTERED 
(
	[GroupID] ASC,
	[PermitRelationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[PPVEventInfo]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PPVEventInfo](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[CASVersion] [int] NOT NULL,
	[CAEveintID] [bigint] NOT NULL,
	[PPVEventName] [nvarchar](64) NOT NULL,
	[ProgramID] [int] NOT NULL,
	[ProviderID] [int] NOT NULL,
	[NeedPoint] [int] NOT NULL,
	[BeginDateTime] [datetime] NOT NULL,
	[EndDateTime] [datetime] NOT NULL,
	[DepartmentID] [int] NOT NULL,
	[Active] [bit] NOT NULL,
	[Creator] [nvarchar](50) NOT NULL,
	[CreateTime] [datetime] NOT NULL,
	[LastEditor] [nvarchar](50) NOT NULL,
	[LastEditTime] [datetime] NOT NULL,
 CONSTRAINT [PK_PPVEVENTINFO] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[PPVProviderInfo]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PPVProviderInfo](
	[ID] [int] NOT NULL,
	[ProviderName] [nvarchar](64) NOT NULL,
	[Remark] [nvarchar](max) NULL,
	[Active] [bit] NOT NULL,
	[Creator] [nvarchar](64) NOT NULL,
	[CreateTime] [datetime] NOT NULL,
	[LastEditor] [nvarchar](64) NOT NULL,
	[LastEditTime] [datetime] NOT NULL,
 CONSTRAINT [PK_PPVPROVIDERINFO] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[PreAuth]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PreAuth](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[StartTime] [datetime] NOT NULL,
	[EndTime] [datetime] NOT NULL,
	[Active] [bit] NOT NULL,
	[Creator] [nvarchar](64) NOT NULL,
	[CreateTime] [datetime] NOT NULL,
 CONSTRAINT [PK_PreAuth] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[PreAuthProduct]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PreAuthProduct](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[PreAuthID] [bigint] NOT NULL,
	[ProductID] [bigint] NOT NULL,
 CONSTRAINT [PK_PreAuthProduct] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[PreferentialTactic]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PreferentialTactic](
	[PreferentialID] [int] IDENTITY(1,1) NOT NULL,
	[TacticID] [int] NOT NULL,
	[PriceType] [int] NOT NULL,
	[Preferential] [int] NOT NULL,
 CONSTRAINT [PK_PREFERENTIALTACTIC] PRIMARY KEY CLUSTERED 
(
	[PreferentialID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[PriceE_Notecase]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PriceE_Notecase](
	[PriceID] [int] IDENTITY(1,1) NOT NULL,
	[PriceCase1] [decimal](12, 4) NOT NULL,
	[PriceCase2] [decimal](12, 4) NOT NULL,
	[PriceCase3] [decimal](12, 4) NOT NULL,
	[PriceCase4] [decimal](12, 4) NOT NULL,
	[DepartmentID] [int] NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NOT NULL,
	[Status] [bit] NOT NULL,
	[Active] [bit] NOT NULL,
	[Remark] [nvarchar](max) NULL,
	[Creator] [nvarchar](64) NOT NULL,
	[CreateTime] [datetime] NOT NULL,
	[LastEditor] [nvarchar](64) NOT NULL,
	[LastEditTime] [datetime] NOT NULL,
 CONSTRAINT [PK_PRICEE_NOTECASE] PRIMARY KEY CLUSTERED 
(
	[PriceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[PriceEquipment]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PriceEquipment](
	[PriceID] [int] IDENTITY(1,1) NOT NULL,
	[ModelNumber] [int] NOT NULL,
	[Price] [decimal](12, 4) NOT NULL,
	[DepartmentID] [int] NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NOT NULL,
	[Status] [bit] NOT NULL,
	[Active] [bit] NOT NULL,
	[Remark] [nvarchar](max) NULL,
	[Creator] [nvarchar](64) NOT NULL,
	[CreateTime] [datetime] NOT NULL,
	[LastEditor] [nvarchar](64) NOT NULL,
	[LastEditTime] [datetime] NOT NULL,
 CONSTRAINT [PK_PRICEEQUIPMENT] PRIMARY KEY CLUSTERED 
(
	[PriceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[PriceOther]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PriceOther](
	[PriceID] [int] IDENTITY(1,1) NOT NULL,
	[PriceType] [int] NOT NULL,
	[Price] [decimal](12, 4) NOT NULL,
	[DepartmentID] [int] NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NOT NULL,
	[Status] [bit] NOT NULL,
	[Active] [bit] NOT NULL,
	[Remark] [nvarchar](max) NULL,
	[Creator] [nvarchar](64) NOT NULL,
	[CreateTime] [datetime] NOT NULL,
	[LastEditor] [nvarchar](64) NOT NULL,
	[LastEditTime] [datetime] NOT NULL,
 CONSTRAINT [PK_PRICEOTHER] PRIMARY KEY CLUSTERED 
(
	[PriceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[PriceProduct]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PriceProduct](
	[PriceID] [int] IDENTITY(1,1) NOT NULL,
	[ProductID] [int] NOT NULL,
	[Price] [decimal](12, 4) NOT NULL,
	[DepartmentID] [int] NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NOT NULL,
	[IsMaster] [bit] NOT NULL,
	[Status] [bit] NOT NULL,
	[Active] [bit] NOT NULL,
	[Remark] [nvarchar](max) NULL,
	[Creator] [nvarchar](64) NOT NULL,
	[CreateTime] [datetime] NOT NULL,
	[LastEditor] [nvarchar](64) NOT NULL,
	[LastEditTime] [datetime] NOT NULL,
 CONSTRAINT [PK_PRICEPRODCUT] PRIMARY KEY CLUSTERED 
(
	[PriceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[PrintBill]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PrintBill](
	[BillNumber] [bigint] IDENTITY(1,1) NOT NULL,
	[RePrintBillNumber] [bigint] NULL,
	[BillID] [bigint] NOT NULL,
	[Creator] [nvarchar](64) NOT NULL,
	[CreateTime] [datetime] NOT NULL,
 CONSTRAINT [PK_PrintBill] PRIMARY KEY CLUSTERED 
(
	[BillNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ProductInfo]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProductInfo](
	[ProductID] [int] IDENTITY(1,1) NOT NULL,
	[CAProductID] [int] NOT NULL,
	[ProductName] [nvarchar](64) NOT NULL,
	[ProductType] [int] NOT NULL,
	[Limit_Flag] [bit] NOT NULL,
	[Match_Flag] [bit] NOT NULL,
	[Active] [bit] NOT NULL,
	[Creator] [nvarchar](50) NOT NULL,
	[CreateTime] [datetime] NOT NULL,
	[LastEditor] [nvarchar](50) NOT NULL,
	[LastEditTime] [datetime] NOT NULL,
 CONSTRAINT [PK__ProductInfo__108B795B] PRIMARY KEY CLUSTERED 
(
	[ProductID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ProductLog]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProductLog](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[ProductID] [int] NULL,
	[CAProductID] [int] NULL,
	[ProductType] [int] NULL,
	[ProductName] [nvarchar](64) NULL,
	[Limit_Flag] [bit] NULL,
	[Match_Flag] [bit] NULL,
	[Creator] [nvarchar](64) NULL,
	[CreateTime] [datetime] NULL,
	[Flag] [bit] NULL,
 CONSTRAINT [PK_ProductLog] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ProductProgramRelation]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProductProgramRelation](
	[ProgramID] [int] NOT NULL,
	[ProductID] [int] NOT NULL,
 CONSTRAINT [PK_PRODUCTPROGRAMRELATION] PRIMARY KEY CLUSTERED 
(
	[ProgramID] ASC,
	[ProductID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ProductProgramRelationLog]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProductProgramRelationLog](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[ProductLogID] [bigint] NULL,
	[ProgramID] [bigint] NULL,
 CONSTRAINT [PK_ProductProgramRelationLog] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ProgramFingerprintFor4]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProgramFingerprintFor4](
	[ProgramID] [int] NOT NULL,
	[DisplayPositionCode] [int] NOT NULL,
	[IsShow] [bit] NOT NULL,
 CONSTRAINT [PK_ProgramFingerprintFor4] PRIMARY KEY CLUSTERED 
(
	[ProgramID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ProgramFingerprintFor5]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProgramFingerprintFor5](
	[ProgramID] [int] NOT NULL,
	[DisplayPositionCode] [int] NOT NULL,
	[PositionX] [smallint] NOT NULL,
	[PositionY] [smallint] NOT NULL,
	[FontType] [int] NOT NULL,
	[FontSize] [int] NOT NULL,
	[FontColor] [int] NOT NULL,
	[BackgroudColor] [int] NOT NULL,
	[IsShow] [bit] NOT NULL,
 CONSTRAINT [PK_ProgramFingerprintFor5] PRIMARY KEY CLUSTERED 
(
	[ProgramID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ProgramFingerprintFor6]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProgramFingerprintFor6](
	[ProgramID] [int] NOT NULL,
	[DisplayPositionCode] [int] NOT NULL,
	[PositionX] [smallint] NOT NULL,
	[PositionY] [smallint] NOT NULL,
	[FontType] [int] NOT NULL,
	[FontSize] [int] NOT NULL,
	[FontColor] [int] NOT NULL,
	[BackgroudColor] [int] NOT NULL,
	[ColorTypeCode] [int] NOT NULL,
	[ShowTime] [int] NOT NULL,
	[StopTime] [int] NOT NULL,
	[OvertFlag] [bit] NOT NULL,
	[ShowBackgroundFlag] [bit] NOT NULL,
	[ShowSTBnumberFlag] [bit] NOT NULL,
	[IsShow] [bit] NOT NULL,
 CONSTRAINT [PK_ProgramFingerprintFor6] PRIMARY KEY CLUSTERED 
(
	[ProgramID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ProgramInfo]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProgramInfo](
	[ProgramID] [int] IDENTITY(1,1) NOT NULL,
	[CAProgramID] [int] NOT NULL,
	[BroadcasterID] [bigint] NULL,
	[NetworkID] [int] NOT NULL,
	[TransportStreamID] [int] NOT NULL,
	[ServiceID] [int] NOT NULL,
	[ProgramName] [nvarchar](64) NOT NULL,
	[VisibleLevel] [int] NOT NULL,
	[ProgramTypeCode] [int] NOT NULL,
	[Active] [bit] NOT NULL,
	[Creator] [nvarchar](50) NOT NULL,
	[CreateTime] [datetime] NOT NULL,
	[LastEditor] [nvarchar](50) NOT NULL,
	[LastEditTime] [datetime] NOT NULL,
 CONSTRAINT [PK__ProgramInfo__09DE7BCC] PRIMARY KEY CLUSTERED 
(
	[ProgramID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ProgramLog]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProgramLog](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[ProgramID] [int] NOT NULL,
	[CAProgramID] [int] NOT NULL,
	[BroadcasterID] [bigint] NULL,
	[ProgramName] [nvarchar](64) NOT NULL,
	[Fingerprint] [bit] NOT NULL,
	[VisibleLevel] [int] NULL,
	[ProgramType] [int] NOT NULL,
	[Creator] [nvarchar](50) NOT NULL,
	[CreateTime] [datetime] NOT NULL,
	[NetworkID] [int] NULL,
	[TransportStreamID] [int] NULL,
	[ServiceID] [int] NULL,
 CONSTRAINT [PK__ProgramLog__09DE7BCC] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ProviderInfo]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProviderInfo](
	[ModelNumber] [int] IDENTITY(1,1) NOT NULL,
	[ProviderTypeCode] [int] NOT NULL,
	[ModelName] [nvarchar](64) NULL,
	[ProviderName] [nvarchar](64) NOT NULL,
	[CAID] [int] NOT NULL,
	[Remark] [nvarchar](max) NULL,
	[Active] [bit] NOT NULL,
	[Creator] [nvarchar](64) NOT NULL,
	[CreateTime] [datetime] NOT NULL,
	[LastEditor] [nvarchar](64) NOT NULL,
	[LastEditTime] [datetime] NOT NULL,
 CONSTRAINT [PK_ProviderInfo] PRIMARY KEY CLUSTERED 
(
	[ModelNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[SignContract]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SignContract](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[Creator] [nvarchar](50) NOT NULL,
	[CreateTime] [datetime] NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NOT NULL,
	[CustomerID] [bigint] NOT NULL,
	[Remark] [nvarchar](max) NULL,
	[Active] [bit] NULL,
 CONSTRAINT [PK_SignContract] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[SignContractDetail]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SignContractDetail](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[ICTableID] [bigint] NULL,
	[ProductID] [bigint] NULL,
	[SignContractID] [bigint] NULL,
 CONSTRAINT [PK_SignContractDetail] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[SMSNote]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SMSNote](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[iICCardNumber] [bigint] NOT NULL,
	[iCardNumber] [nvarchar](64) NOT NULL,
	[ProductID] [int] NOT NULL,
	[iMonth] [int] NOT NULL,
	[operDate] [datetime] NOT NULL,
	[status] [bit] NOT NULL,
 CONSTRAINT [PK__SMSNote__6E01572D] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[STBInfo]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[STBInfo](
	[STBID] [bigint] IDENTITY(1,1) NOT NULL,
	[STBRealNumber] [nvarchar](64) NOT NULL,
	[ModelNumber] [int] NOT NULL,
	[CustomerID] [bigint] NULL,
	[DepartmentID] [int] NULL,
	[Status] [int] NOT NULL,
	[Active] [bit] NOT NULL,
	[Creator] [nvarchar](50) NOT NULL,
	[CreateTime] [datetime] NOT NULL,
	[LastEditor] [nvarchar](50) NOT NULL,
	[LastEditTime] [datetime] NOT NULL,
 CONSTRAINT [PK_STBINFO] PRIMARY KEY CLUSTERED 
(
	[STBID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Stop]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Stop](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[UserCostID] [bigint] NULL,
	[CustomerID] [bigint] NOT NULL,
	[ICTableID] [bigint] NOT NULL,
	[StopDate] [datetime] NOT NULL,
	[OpenDate] [datetime] NULL,
	[OrderFeePackageID] [bigint] NULL,
	[PriceID] [bigint] NOT NULL,
	[Price] [decimal](12, 4) NOT NULL,
	[PreferentialID] [bigint] NULL,
	[Preferential] [decimal](12, 4) NOT NULL,
	[OriginalFee] [decimal](12, 4) NOT NULL,
	[RealFee] [decimal](12, 4) NOT NULL,
	[OperateType] [int] NOT NULL,
	[Status] [int] NOT NULL,
	[BackOrderID] [bigint] NULL,
	[Remark] [nvarchar](max) NULL,
	[Creator] [nvarchar](64) NOT NULL,
	[CreateTime] [datetime] NOT NULL,
	[LastEditor] [nvarchar](64) NOT NULL,
	[LastEditTime] [datetime] NOT NULL,
	[PauseCalType] [int] NOT NULL,
 CONSTRAINT [PK_STOP] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[SysFunction]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SysFunction](
	[FunctionID] [int] NOT NULL,
	[ParentFunctionID] [int] NULL,
	[FunctionCode] [nvarchar](64) NOT NULL,
	[FunctionName] [nvarchar](64) NOT NULL,
	[Layer] [nvarchar](50) NOT NULL,
	[Controller] [nvarchar](50) NULL,
	[Action] [nvarchar](50) NULL,
	[Visible] [bit] NOT NULL,
	[SortSetting] [int] NOT NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[SystemSetting]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SystemSetting](
	[Key] [nvarchar](20) NOT NULL,
	[Value] [nvarchar](50) NOT NULL,
	[Comment] [nvarchar](255) NULL,
 CONSTRAINT [PK_SYSTEMSETTING] PRIMARY KEY CLUSTERED 
(
	[Key] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[TacticPreferential]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TacticPreferential](
	[TacticID] [int] IDENTITY(1,1) NOT NULL,
	[TacticName] [nvarchar](64) NOT NULL,
	[CustTypeID] [int] NOT NULL,
	[DepartmentID] [int] NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NOT NULL,
	[Status] [bit] NOT NULL,
	[Active] [bit] NOT NULL,
	[Remark] [nvarchar](max) NULL,
	[Creator] [nvarchar](64) NOT NULL,
	[CreateTime] [datetime] NOT NULL,
	[LastEditor] [nvarchar](64) NOT NULL,
	[LastEditTime] [datetime] NOT NULL,
 CONSTRAINT [PK_TACTICPREFERENTIAL] PRIMARY KEY CLUSTERED 
(
	[TacticID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[UserCost]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserCost](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[CustomerID] [bigint] NOT NULL,
	[CustomerTypeID] [int] NOT NULL,
	[ChargeTime] [datetime] NOT NULL,
	[TacticPreferentialID] [int] NULL,
	[RealFee] [decimal](12, 4) NOT NULL,
	[OriginalFee] [decimal](12, 4) NOT NULL,
	[IsPaid] [bit] NOT NULL,
	[ChargeCash] [decimal](12, 4) NOT NULL,
	[ChargeBalance] [decimal](12, 4) NOT NULL,
	[Creator] [nvarchar](64) NOT NULL,
	[CreateTime] [datetime] NOT NULL,
	[LastEditor] [nvarchar](64) NOT NULL,
	[LastEditTime] [datetime] NOT NULL,
	[DailyID] [bigint] NULL,
	[ChargeUser] [nvarchar](64) NULL,
 CONSTRAINT [PK_USERCOST] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[UserInfo]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserInfo](
	[UserID] [nvarchar](64) NOT NULL,
	[UserName] [nvarchar](64) NOT NULL,
	[Password] [nvarchar](64) NOT NULL,
	[Sex] [int] NOT NULL,
	[PhoneNumber] [nvarchar](64) NULL,
	[MasterDepartmentID] [int] NOT NULL,
	[DepartmentID] [int] NOT NULL,
	[Active] [bit] NOT NULL,
	[Creator] [nvarchar](64) NOT NULL,
	[CreateTime] [datetime] NOT NULL,
	[LastEditor] [nvarchar](64) NOT NULL,
	[LastEditTime] [datetime] NOT NULL,
 CONSTRAINT [PK__UserInfo__30F848ED] PRIMARY KEY CLUSTERED 
(
	[UserID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[UserInfo_Group_Relation]    Script Date: 02-06-2019 00:06:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserInfo_Group_Relation](
	[UserID] [nvarchar](64) NOT NULL,
	[GroupID] [int] NOT NULL,
 CONSTRAINT [PK_USERINFO_GROUP_RELATION] PRIMARY KEY CLUSTERED 
(
	[UserID] ASC,
	[GroupID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET IDENTITY_INSERT [dbo].[AddressRegion] ON 

INSERT [dbo].[AddressRegion] ([RegionID], [RegionName], [ParentRegionID], [Layer], [Active], [Creator], [CreateTime], [LastEditor], [LastEditTime]) VALUES (1, N'All Region', NULL, N'0000000000000000', 1, N'Admin', CAST(0x0000AA5300DFDB8A AS DateTime), N'Admin', CAST(0x0000AA5300DFDB8A AS DateTime))
INSERT [dbo].[AddressRegion] ([RegionID], [RegionName], [ParentRegionID], [Layer], [Active], [Creator], [CreateTime], [LastEditor], [LastEditTime]) VALUES (2, N'GANDHINAGAR', 1, N'0001000000000000', 1, N'admin', CAST(0x0000AA5300E1477C AS DateTime), N'admin', CAST(0x0000AA5300E1477C AS DateTime))
SET IDENTITY_INSERT [dbo].[AddressRegion] OFF
SET IDENTITY_INSERT [dbo].[AuthInfo] ON 

INSERT [dbo].[AuthInfo] ([ID], [ICTableID], [ProductID], [StartDate], [EndDate], [OrderProductID]) VALUES (11, 3, 3, CAST(0x0000AA5300000000 AS DateTime), CAST(0x0000ABC100000000 AS DateTime), 29)
SET IDENTITY_INSERT [dbo].[AuthInfo] OFF
INSERT [dbo].[BaseData] ([CodeType], [CodeTypeName], [Code], [CodeValue], [Remark]) VALUES (N'FeeModel', N'计费模式', N'0', N'FeeModelOrder', N'订购模式')
INSERT [dbo].[BaseData] ([CodeType], [CodeTypeName], [Code], [CodeValue], [Remark]) VALUES (N'FeeModel', N'计费模式', N'1', N'FeeModelPrestore', N'预存模式')
INSERT [dbo].[BaseData] ([CodeType], [CodeTypeName], [Code], [CodeValue], [Remark]) VALUES (N'ICStatus', N'IC卡状态', N'0', N'CARD_CANCELED', NULL)
INSERT [dbo].[BaseData] ([CodeType], [CodeTypeName], [Code], [CodeValue], [Remark]) VALUES (N'ICStatus', N'IC卡状态', N'1', N'CARD_ACTIVATE', NULL)
INSERT [dbo].[BaseData] ([CodeType], [CodeTypeName], [Code], [CodeValue], [Remark]) VALUES (N'ICStatus', N'IC卡状态', N'2', N'CARD_STOP', NULL)
INSERT [dbo].[BaseData] ([CodeType], [CodeTypeName], [Code], [CodeValue], [Remark]) VALUES (N'ICStatus', N'IC卡状态', N'3', N'CARD_PENDING', NULL)
INSERT [dbo].[BaseData] ([CodeType], [CodeTypeName], [Code], [CodeValue], [Remark]) VALUES (N'OperateTypes', N'操作类型', N'1', N'Order', N'订购')
INSERT [dbo].[BaseData] ([CodeType], [CodeTypeName], [Code], [CodeValue], [Remark]) VALUES (N'OperateTypes', N'操作类型', N'2', N'UnOrder', N'退订')
INSERT [dbo].[BaseData] ([CodeType], [CodeTypeName], [Code], [CodeValue], [Remark]) VALUES (N'OperateTypes', N'操作类型', N'3', N'ExceptionBack', N'异常处理')
INSERT [dbo].[BaseData] ([CodeType], [CodeTypeName], [Code], [CodeValue], [Remark]) VALUES (N'OperateTypes', N'操作类型', N'4', N'ChangeEqpt', N'更换设备')
INSERT [dbo].[BaseData] ([CodeType], [CodeTypeName], [Code], [CodeValue], [Remark]) VALUES (N'OrderStatus', N'订购状态', N'0', N'Uneffective', N'无效')
INSERT [dbo].[BaseData] ([CodeType], [CodeTypeName], [Code], [CodeValue], [Remark]) VALUES (N'OrderStatus', N'订购状态', N'1', N'Effective', N'正常有效')
INSERT [dbo].[BaseData] ([CodeType], [CodeTypeName], [Code], [CodeValue], [Remark]) VALUES (N'OrderStatus', N'订购状态', N'2', N'BackOrder', N'被退订')
INSERT [dbo].[BaseData] ([CodeType], [CodeTypeName], [Code], [CodeValue], [Remark]) VALUES (N'OrderStatus', N'订购状态', N'3', N'Exception', N'被异常处理')
INSERT [dbo].[BaseData] ([CodeType], [CodeTypeName], [Code], [CodeValue], [Remark]) VALUES (N'PriceType', N'费用类型', N'1', N'Init', NULL)
INSERT [dbo].[BaseData] ([CodeType], [CodeTypeName], [Code], [CodeValue], [Remark]) VALUES (N'PriceType', N'费用类型', N'2', N'OrderCard', NULL)
INSERT [dbo].[BaseData] ([CodeType], [CodeTypeName], [Code], [CodeValue], [Remark]) VALUES (N'PriceType', N'费用类型', N'3', N'OrderSTB', NULL)
INSERT [dbo].[BaseData] ([CodeType], [CodeTypeName], [Code], [CodeValue], [Remark]) VALUES (N'PriceType', N'费用类型', N'4', N'OrderProduct', NULL)
INSERT [dbo].[BaseData] ([CodeType], [CodeTypeName], [Code], [CodeValue], [Remark]) VALUES (N'PriceType', N'费用类型', N'5', N'E_Notecase', NULL)
INSERT [dbo].[BaseData] ([CodeType], [CodeTypeName], [Code], [CodeValue], [Remark]) VALUES (N'PriceType', N'费用类型', N'6', N'Stop', NULL)
INSERT [dbo].[BaseData] ([CodeType], [CodeTypeName], [Code], [CodeValue], [Remark]) VALUES (N'PriceType', N'费用类型', N'7', N'OrderProductSlave', NULL)
INSERT [dbo].[BaseData] ([CodeType], [CodeTypeName], [Code], [CodeValue], [Remark]) VALUES (N'ProgramType', N'节目类型', N'0', N'ProgramTypeNormal', N'??')
INSERT [dbo].[BaseData] ([CodeType], [CodeTypeName], [Code], [CodeValue], [Remark]) VALUES (N'ProgramType', N'节目类型', N'1', N'ProgramTypePPV', N'')
INSERT [dbo].[BaseData] ([CodeType], [CodeTypeName], [Code], [CodeValue], [Remark]) VALUES (N'RenewOriginateTypes', N'缴费来源', N'1', N'Order', N'订购')
INSERT [dbo].[BaseData] ([CodeType], [CodeTypeName], [Code], [CodeValue], [Remark]) VALUES (N'RenewOriginateTypes', N'缴费来源', N'2', N'EasyPay', N'短信充值')
INSERT [dbo].[BaseData] ([CodeType], [CodeTypeName], [Code], [CodeValue], [Remark]) VALUES (N'RenewOriginateTypes', N'缴费来源', N'3', N'Prestore', N'预存')
INSERT [dbo].[BaseData] ([CodeType], [CodeTypeName], [Code], [CodeValue], [Remark]) VALUES (N'RenewTypes', N'续费方式', N'1', N'CurrentOrder', N'当前时间')
INSERT [dbo].[BaseData] ([CodeType], [CodeTypeName], [Code], [CodeValue], [Remark]) VALUES (N'RenewTypes', N'续费方式', N'2', N'LastOrder', N'最后结束时间')
INSERT [dbo].[BaseData] ([CodeType], [CodeTypeName], [Code], [CodeValue], [Remark]) VALUES (N'SendPriority', N'发送优先级', N'0', N'PRIORITY_NORMAL', NULL)
INSERT [dbo].[BaseData] ([CodeType], [CodeTypeName], [Code], [CodeValue], [Remark]) VALUES (N'SendPriority', N'发送优先级', N'1', N'PRIORITY_HIGH', NULL)
INSERT [dbo].[BaseData] ([CodeType], [CodeTypeName], [Code], [CodeValue], [Remark]) VALUES (N'SendPriority', N'发送优先级', N'2', N'PRIORITY_REALTIME', NULL)
INSERT [dbo].[BaseData] ([CodeType], [CodeTypeName], [Code], [CodeValue], [Remark]) VALUES (N'VisibleLevel', N'收看级别', N'1', N'1', NULL)
INSERT [dbo].[BaseData] ([CodeType], [CodeTypeName], [Code], [CodeValue], [Remark]) VALUES (N'VisibleLevel', N'收看级别', N'2', N'2', NULL)
INSERT [dbo].[BaseData] ([CodeType], [CodeTypeName], [Code], [CodeValue], [Remark]) VALUES (N'VisibleLevel', N'收看级别', N'3', N'3', NULL)
INSERT [dbo].[BaseData] ([CodeType], [CodeTypeName], [Code], [CodeValue], [Remark]) VALUES (N'VisibleLevel', N'收看级别', N'4', N'4', NULL)
INSERT [dbo].[BaseData] ([CodeType], [CodeTypeName], [Code], [CodeValue], [Remark]) VALUES (N'VisibleLevel', N'收看级别', N'5', N'5', NULL)
INSERT [dbo].[BaseData] ([CodeType], [CodeTypeName], [Code], [CodeValue], [Remark]) VALUES (N'VisibleLevel', N'收看级别', N'6', N'6', NULL)
INSERT [dbo].[BaseData] ([CodeType], [CodeTypeName], [Code], [CodeValue], [Remark]) VALUES (N'VisibleLevel', N'收看级别', N'7', N'7', NULL)
INSERT [dbo].[BaseData] ([CodeType], [CodeTypeName], [Code], [CodeValue], [Remark]) VALUES (N'VisibleLevel', N'收看级别', N'8', N'8', NULL)
INSERT [dbo].[BaseData] ([CodeType], [CodeTypeName], [Code], [CodeValue], [Remark]) VALUES (N'VisibleLevel', N'收看级别', N'9', N'9', NULL)
SET IDENTITY_INSERT [dbo].[BillDetail] ON 

INSERT [dbo].[BillDetail] ([ID], [BillID], [PriceType], [OrderID], [OrderFeePackageID], [PackageID], [PackageName], [ICNumber], [STBNumber], [ProductID], [ProductName], [StartTime], [EndTime], [PriceID], [PreferentialID], [OriginalFee], [PreferentialFee], [RealFee], [Remark], [OperateType]) VALUES (1, 1, 1, 1, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL, CAST(0.0000 AS Decimal(14, 4)), CAST(0.0000 AS Decimal(14, 4)), CAST(0.0000 AS Decimal(14, 4)), NULL, 0)
INSERT [dbo].[BillDetail] ([ID], [BillID], [PriceType], [OrderID], [OrderFeePackageID], [PackageID], [PackageName], [ICNumber], [STBNumber], [ProductID], [ProductName], [StartTime], [EndTime], [PriceID], [PreferentialID], [OriginalFee], [PreferentialFee], [RealFee], [Remark], [OperateType]) VALUES (2, 1, 2, 1, 0, 0, NULL, N'796', NULL, NULL, NULL, NULL, NULL, 2, NULL, CAST(250.0000 AS Decimal(14, 4)), CAST(0.0000 AS Decimal(14, 4)), CAST(250.0000 AS Decimal(14, 4)), NULL, 0)
INSERT [dbo].[BillDetail] ([ID], [BillID], [PriceType], [OrderID], [OrderFeePackageID], [PackageID], [PackageName], [ICNumber], [STBNumber], [ProductID], [ProductName], [StartTime], [EndTime], [PriceID], [PreferentialID], [OriginalFee], [PreferentialFee], [RealFee], [Remark], [OperateType]) VALUES (3, 1, 3, 1, 0, 0, NULL, NULL, N'8778788000007966', NULL, NULL, NULL, NULL, 1, NULL, CAST(1200.0000 AS Decimal(14, 4)), CAST(0.0000 AS Decimal(14, 4)), CAST(1200.0000 AS Decimal(14, 4)), NULL, 0)
INSERT [dbo].[BillDetail] ([ID], [BillID], [PriceType], [OrderID], [OrderFeePackageID], [PackageID], [PackageName], [ICNumber], [STBNumber], [ProductID], [ProductName], [StartTime], [EndTime], [PriceID], [PreferentialID], [OriginalFee], [PreferentialFee], [RealFee], [Remark], [OperateType]) VALUES (4, 1, 4, 1, 0, 0, NULL, N'796', NULL, 3, N'ALL PACKAGE', CAST(0x0000AA5300000000 AS DateTime), CAST(0x0000ABC100000000 AS DateTime), 1, NULL, CAST(3000.0000 AS Decimal(14, 4)), CAST(0.0000 AS Decimal(14, 4)), CAST(3000.0000 AS Decimal(14, 4)), N'', 1)
INSERT [dbo].[BillDetail] ([ID], [BillID], [PriceType], [OrderID], [OrderFeePackageID], [PackageID], [PackageName], [ICNumber], [STBNumber], [ProductID], [ProductName], [StartTime], [EndTime], [PriceID], [PreferentialID], [OriginalFee], [PreferentialFee], [RealFee], [Remark], [OperateType]) VALUES (5, 2, 4, 3, 0, 0, NULL, N'796', NULL, 3, N'ALL PACKAGE', CAST(0x0000AA5300000000 AS DateTime), CAST(0x0000ABC100000000 AS DateTime), 1, NULL, CAST(0.0000 AS Decimal(14, 4)), CAST(0.0000 AS Decimal(14, 4)), CAST(-3000.0000 AS Decimal(14, 4)), N'Unsubscribed ICNumber [1] IC [796-8778788000007966]', 2)
INSERT [dbo].[BillDetail] ([ID], [BillID], [PriceType], [OrderID], [OrderFeePackageID], [PackageID], [PackageName], [ICNumber], [STBNumber], [ProductID], [ProductName], [StartTime], [EndTime], [PriceID], [PreferentialID], [OriginalFee], [PreferentialFee], [RealFee], [Remark], [OperateType]) VALUES (6, 3, 4, 5, 0, 0, NULL, N'796', NULL, 3, N'ALL PACKAGE', CAST(0x0000AA5300000000 AS DateTime), CAST(0x0000ABC100000000 AS DateTime), 1, NULL, CAST(3000.0000 AS Decimal(14, 4)), CAST(0.0000 AS Decimal(14, 4)), CAST(3000.0000 AS Decimal(14, 4)), N'', 1)
INSERT [dbo].[BillDetail] ([ID], [BillID], [PriceType], [OrderID], [OrderFeePackageID], [PackageID], [PackageName], [ICNumber], [STBNumber], [ProductID], [ProductName], [StartTime], [EndTime], [PriceID], [PreferentialID], [OriginalFee], [PreferentialFee], [RealFee], [Remark], [OperateType]) VALUES (7, 4, 4, 7, 0, 0, NULL, N'796', NULL, 3, N'ALL PACKAGE', CAST(0x0000AA5300000000 AS DateTime), CAST(0x0000ABC100000000 AS DateTime), 1, NULL, CAST(0.0000 AS Decimal(14, 4)), CAST(0.0000 AS Decimal(14, 4)), CAST(-3000.0000 AS Decimal(14, 4)), N'Unsubscribed ICNumber [5] IC [796-8778788000007966]', 2)
INSERT [dbo].[BillDetail] ([ID], [BillID], [PriceType], [OrderID], [OrderFeePackageID], [PackageID], [PackageName], [ICNumber], [STBNumber], [ProductID], [ProductName], [StartTime], [EndTime], [PriceID], [PreferentialID], [OriginalFee], [PreferentialFee], [RealFee], [Remark], [OperateType]) VALUES (8, 5, 4, 9, 0, 0, NULL, N'796', NULL, 3, N'ALL PACKAGE', CAST(0x0000AA5300000000 AS DateTime), CAST(0x0000ABC100000000 AS DateTime), 1, NULL, CAST(3000.0000 AS Decimal(14, 4)), CAST(0.0000 AS Decimal(14, 4)), CAST(3000.0000 AS Decimal(14, 4)), N'', 1)
INSERT [dbo].[BillDetail] ([ID], [BillID], [PriceType], [OrderID], [OrderFeePackageID], [PackageID], [PackageName], [ICNumber], [STBNumber], [ProductID], [ProductName], [StartTime], [EndTime], [PriceID], [PreferentialID], [OriginalFee], [PreferentialFee], [RealFee], [Remark], [OperateType]) VALUES (9, 6, 4, 11, 0, 0, NULL, N'796', NULL, 3, N'ALL PACKAGE', CAST(0x0000AA5300000000 AS DateTime), CAST(0x0000ABC100000000 AS DateTime), 1, NULL, CAST(0.0000 AS Decimal(14, 4)), CAST(0.0000 AS Decimal(14, 4)), CAST(-3000.0000 AS Decimal(14, 4)), N'Unsubscribed ICNumber [9] IC [796-8778788000007966]', 2)
INSERT [dbo].[BillDetail] ([ID], [BillID], [PriceType], [OrderID], [OrderFeePackageID], [PackageID], [PackageName], [ICNumber], [STBNumber], [ProductID], [ProductName], [StartTime], [EndTime], [PriceID], [PreferentialID], [OriginalFee], [PreferentialFee], [RealFee], [Remark], [OperateType]) VALUES (10, 7, 4, 13, 0, 0, NULL, N'796', NULL, 3, N'ALL PACKAGE', CAST(0x0000AA5300000000 AS DateTime), CAST(0x0000ABC100000000 AS DateTime), 1, NULL, CAST(3000.0000 AS Decimal(14, 4)), CAST(0.0000 AS Decimal(14, 4)), CAST(3000.0000 AS Decimal(14, 4)), N'', 1)
INSERT [dbo].[BillDetail] ([ID], [BillID], [PriceType], [OrderID], [OrderFeePackageID], [PackageID], [PackageName], [ICNumber], [STBNumber], [ProductID], [ProductName], [StartTime], [EndTime], [PriceID], [PreferentialID], [OriginalFee], [PreferentialFee], [RealFee], [Remark], [OperateType]) VALUES (11, 8, 4, 16, 0, 0, NULL, N'796', NULL, 3, N'ALL PACKAGE', CAST(0x0000AA5300000000 AS DateTime), CAST(0x0000ABC100000000 AS DateTime), 1, NULL, CAST(0.0000 AS Decimal(14, 4)), CAST(0.0000 AS Decimal(14, 4)), CAST(-3000.0000 AS Decimal(14, 4)), N'Unsubscribed ICNumber [13] IC [796-8778788000007966]', 2)
INSERT [dbo].[BillDetail] ([ID], [BillID], [PriceType], [OrderID], [OrderFeePackageID], [PackageID], [PackageName], [ICNumber], [STBNumber], [ProductID], [ProductName], [StartTime], [EndTime], [PriceID], [PreferentialID], [OriginalFee], [PreferentialFee], [RealFee], [Remark], [OperateType]) VALUES (12, 9, 4, 17, 0, 0, NULL, N'796', NULL, 3, N'ALL PACKAGE', CAST(0x0000AA5300000000 AS DateTime), CAST(0x0000ABC100000000 AS DateTime), 1, NULL, CAST(3000.0000 AS Decimal(14, 4)), CAST(0.0000 AS Decimal(14, 4)), CAST(3000.0000 AS Decimal(14, 4)), N'', 1)
INSERT [dbo].[BillDetail] ([ID], [BillID], [PriceType], [OrderID], [OrderFeePackageID], [PackageID], [PackageName], [ICNumber], [STBNumber], [ProductID], [ProductName], [StartTime], [EndTime], [PriceID], [PreferentialID], [OriginalFee], [PreferentialFee], [RealFee], [Remark], [OperateType]) VALUES (13, 10, 4, 19, 0, 0, NULL, N'796', NULL, 3, N'ALL PACKAGE', CAST(0x0000AA5300000000 AS DateTime), CAST(0x0000ABC100000000 AS DateTime), 1, NULL, CAST(0.0000 AS Decimal(14, 4)), CAST(0.0000 AS Decimal(14, 4)), CAST(-3000.0000 AS Decimal(14, 4)), N'Unsubscribed ICNumber [17] IC [796-8778788000007966]', 2)
INSERT [dbo].[BillDetail] ([ID], [BillID], [PriceType], [OrderID], [OrderFeePackageID], [PackageID], [PackageName], [ICNumber], [STBNumber], [ProductID], [ProductName], [StartTime], [EndTime], [PriceID], [PreferentialID], [OriginalFee], [PreferentialFee], [RealFee], [Remark], [OperateType]) VALUES (14, 11, 1, 2, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL, CAST(0.0000 AS Decimal(14, 4)), CAST(0.0000 AS Decimal(14, 4)), CAST(0.0000 AS Decimal(14, 4)), NULL, 0)
INSERT [dbo].[BillDetail] ([ID], [BillID], [PriceType], [OrderID], [OrderFeePackageID], [PackageID], [PackageName], [ICNumber], [STBNumber], [ProductID], [ProductName], [StartTime], [EndTime], [PriceID], [PreferentialID], [OriginalFee], [PreferentialFee], [RealFee], [Remark], [OperateType]) VALUES (15, 11, 2, 2, 0, 0, NULL, N'796', NULL, NULL, NULL, NULL, NULL, 2, NULL, CAST(250.0000 AS Decimal(14, 4)), CAST(0.0000 AS Decimal(14, 4)), CAST(250.0000 AS Decimal(14, 4)), NULL, 0)
INSERT [dbo].[BillDetail] ([ID], [BillID], [PriceType], [OrderID], [OrderFeePackageID], [PackageID], [PackageName], [ICNumber], [STBNumber], [ProductID], [ProductName], [StartTime], [EndTime], [PriceID], [PreferentialID], [OriginalFee], [PreferentialFee], [RealFee], [Remark], [OperateType]) VALUES (16, 11, 3, 2, 0, 0, NULL, NULL, N'8778788000007966', NULL, NULL, NULL, NULL, 1, NULL, CAST(1200.0000 AS Decimal(14, 4)), CAST(0.0000 AS Decimal(14, 4)), CAST(1200.0000 AS Decimal(14, 4)), NULL, 0)
INSERT [dbo].[BillDetail] ([ID], [BillID], [PriceType], [OrderID], [OrderFeePackageID], [PackageID], [PackageName], [ICNumber], [STBNumber], [ProductID], [ProductName], [StartTime], [EndTime], [PriceID], [PreferentialID], [OriginalFee], [PreferentialFee], [RealFee], [Remark], [OperateType]) VALUES (17, 11, 4, 21, 0, 0, NULL, N'796', NULL, 3, N'ALL PACKAGE', CAST(0x0000AA5300000000 AS DateTime), CAST(0x0000ABC100000000 AS DateTime), 1, NULL, CAST(3000.0000 AS Decimal(14, 4)), CAST(0.0000 AS Decimal(14, 4)), CAST(3000.0000 AS Decimal(14, 4)), N'', 1)
INSERT [dbo].[BillDetail] ([ID], [BillID], [PriceType], [OrderID], [OrderFeePackageID], [PackageID], [PackageName], [ICNumber], [STBNumber], [ProductID], [ProductName], [StartTime], [EndTime], [PriceID], [PreferentialID], [OriginalFee], [PreferentialFee], [RealFee], [Remark], [OperateType]) VALUES (18, 12, 4, 23, 0, 0, NULL, N'796', NULL, 3, N'ALL PACKAGE', CAST(0x0000AA5300000000 AS DateTime), CAST(0x0000ABC100000000 AS DateTime), 1, NULL, CAST(0.0000 AS Decimal(14, 4)), CAST(0.0000 AS Decimal(14, 4)), CAST(-3000.0000 AS Decimal(14, 4)), N'Unsubscribed ICNumber [21] IC [796-8778788000007966]', 2)
INSERT [dbo].[BillDetail] ([ID], [BillID], [PriceType], [OrderID], [OrderFeePackageID], [PackageID], [PackageName], [ICNumber], [STBNumber], [ProductID], [ProductName], [StartTime], [EndTime], [PriceID], [PreferentialID], [OriginalFee], [PreferentialFee], [RealFee], [Remark], [OperateType]) VALUES (19, 13, 4, 25, 0, 0, NULL, N'796', NULL, 3, N'ALL PACKAGE', CAST(0x0000AA5300000000 AS DateTime), CAST(0x0000ABC100000000 AS DateTime), 1, NULL, CAST(3000.0000 AS Decimal(14, 4)), CAST(0.0000 AS Decimal(14, 4)), CAST(3000.0000 AS Decimal(14, 4)), N'', 1)
INSERT [dbo].[BillDetail] ([ID], [BillID], [PriceType], [OrderID], [OrderFeePackageID], [PackageID], [PackageName], [ICNumber], [STBNumber], [ProductID], [ProductName], [StartTime], [EndTime], [PriceID], [PreferentialID], [OriginalFee], [PreferentialFee], [RealFee], [Remark], [OperateType]) VALUES (20, 14, 4, 27, 0, 0, NULL, N'796', NULL, 3, N'ALL PACKAGE', CAST(0x0000AA5300000000 AS DateTime), CAST(0x0000ABC100000000 AS DateTime), 1, NULL, CAST(0.0000 AS Decimal(14, 4)), CAST(0.0000 AS Decimal(14, 4)), CAST(-3000.0000 AS Decimal(14, 4)), N'Unsubscribed ICNumber [25] IC [796-8778788000007966]', 2)
INSERT [dbo].[BillDetail] ([ID], [BillID], [PriceType], [OrderID], [OrderFeePackageID], [PackageID], [PackageName], [ICNumber], [STBNumber], [ProductID], [ProductName], [StartTime], [EndTime], [PriceID], [PreferentialID], [OriginalFee], [PreferentialFee], [RealFee], [Remark], [OperateType]) VALUES (21, 15, 4, 29, 0, 0, NULL, N'796', NULL, 3, N'ALL PACKAGE', CAST(0x0000AA5300000000 AS DateTime), CAST(0x0000ABC100000000 AS DateTime), 1, NULL, CAST(3000.0000 AS Decimal(14, 4)), CAST(0.0000 AS Decimal(14, 4)), CAST(3000.0000 AS Decimal(14, 4)), N'', 1)
SET IDENTITY_INSERT [dbo].[BillDetail] OFF
SET IDENTITY_INSERT [dbo].[BillInfo] ON 

INSERT [dbo].[BillInfo] ([BillID], [BillNumber], [UserCostID], [CustomerID], [CustomerNumber], [CustomerName], [CustomerType], [ChargeFee], [ChargeCash], [ChargeBalance], [ChargeOther], [RealFee], [LastAdjust], [Adjust], [Remark], [PrintCount], [Creator], [CreateTime]) VALUES (1, N'0000000000000001', 1, 1, N'1', N'SHUBHAM', N'GENERAL', CAST(4450.0000 AS Decimal(14, 4)), CAST(4450.0000 AS Decimal(12, 4)), CAST(0.0000 AS Decimal(12, 4)), CAST(0.0000 AS Decimal(12, 4)), CAST(4450.0000 AS Decimal(14, 4)), CAST(0.0000 AS Decimal(14, 4)), CAST(0.0000 AS Decimal(14, 4)), NULL, 0, N'admin', CAST(0x0000AA5300E5DDB4 AS DateTime))
INSERT [dbo].[BillInfo] ([BillID], [BillNumber], [UserCostID], [CustomerID], [CustomerNumber], [CustomerName], [CustomerType], [ChargeFee], [ChargeCash], [ChargeBalance], [ChargeOther], [RealFee], [LastAdjust], [Adjust], [Remark], [PrintCount], [Creator], [CreateTime]) VALUES (2, N'0000000000000002', 2, 1, N'1', N'SHUBHAM', N'GENERAL', CAST(-3000.0000 AS Decimal(14, 4)), CAST(-3000.0000 AS Decimal(12, 4)), CAST(0.0000 AS Decimal(12, 4)), CAST(0.0000 AS Decimal(12, 4)), CAST(-3000.0000 AS Decimal(14, 4)), CAST(0.0000 AS Decimal(14, 4)), CAST(0.0000 AS Decimal(14, 4)), NULL, 0, N'admin', CAST(0x0000AA5300E61144 AS DateTime))
INSERT [dbo].[BillInfo] ([BillID], [BillNumber], [UserCostID], [CustomerID], [CustomerNumber], [CustomerName], [CustomerType], [ChargeFee], [ChargeCash], [ChargeBalance], [ChargeOther], [RealFee], [LastAdjust], [Adjust], [Remark], [PrintCount], [Creator], [CreateTime]) VALUES (3, N'0000000000000003', 3, 1, N'1', N'SHUBHAM', N'GENERAL', CAST(3000.0000 AS Decimal(14, 4)), CAST(3000.0000 AS Decimal(12, 4)), CAST(0.0000 AS Decimal(12, 4)), CAST(0.0000 AS Decimal(12, 4)), CAST(3000.0000 AS Decimal(14, 4)), CAST(0.0000 AS Decimal(14, 4)), CAST(0.0000 AS Decimal(14, 4)), NULL, 0, N'admin', CAST(0x0000AA5300E6265C AS DateTime))
INSERT [dbo].[BillInfo] ([BillID], [BillNumber], [UserCostID], [CustomerID], [CustomerNumber], [CustomerName], [CustomerType], [ChargeFee], [ChargeCash], [ChargeBalance], [ChargeOther], [RealFee], [LastAdjust], [Adjust], [Remark], [PrintCount], [Creator], [CreateTime]) VALUES (4, N'0000000000000004', 4, 1, N'1', N'SHUBHAM', N'GENERAL', CAST(-3000.0000 AS Decimal(14, 4)), CAST(-3000.0000 AS Decimal(12, 4)), CAST(0.0000 AS Decimal(12, 4)), CAST(0.0000 AS Decimal(12, 4)), CAST(-3000.0000 AS Decimal(14, 4)), CAST(0.0000 AS Decimal(14, 4)), CAST(0.0000 AS Decimal(14, 4)), NULL, 0, N'admin', CAST(0x0000AA5300E6E560 AS DateTime))
INSERT [dbo].[BillInfo] ([BillID], [BillNumber], [UserCostID], [CustomerID], [CustomerNumber], [CustomerName], [CustomerType], [ChargeFee], [ChargeCash], [ChargeBalance], [ChargeOther], [RealFee], [LastAdjust], [Adjust], [Remark], [PrintCount], [Creator], [CreateTime]) VALUES (5, N'0000000000000005', 5, 1, N'1', N'SHUBHAM', N'GENERAL', CAST(3000.0000 AS Decimal(14, 4)), CAST(3000.0000 AS Decimal(12, 4)), CAST(0.0000 AS Decimal(12, 4)), CAST(0.0000 AS Decimal(12, 4)), CAST(3000.0000 AS Decimal(14, 4)), CAST(0.0000 AS Decimal(14, 4)), CAST(0.0000 AS Decimal(14, 4)), NULL, 0, N'admin', CAST(0x0000AA5300E7606C AS DateTime))
INSERT [dbo].[BillInfo] ([BillID], [BillNumber], [UserCostID], [CustomerID], [CustomerNumber], [CustomerName], [CustomerType], [ChargeFee], [ChargeCash], [ChargeBalance], [ChargeOther], [RealFee], [LastAdjust], [Adjust], [Remark], [PrintCount], [Creator], [CreateTime]) VALUES (6, N'0000000000000006', 6, 1, N'1', N'SHUBHAM', N'GENERAL', CAST(-3000.0000 AS Decimal(14, 4)), CAST(-3000.0000 AS Decimal(12, 4)), CAST(0.0000 AS Decimal(12, 4)), CAST(0.0000 AS Decimal(12, 4)), CAST(-3000.0000 AS Decimal(14, 4)), CAST(0.0000 AS Decimal(14, 4)), CAST(0.0000 AS Decimal(14, 4)), NULL, 0, N'admin', CAST(0x0000AA5300E7C1B0 AS DateTime))
INSERT [dbo].[BillInfo] ([BillID], [BillNumber], [UserCostID], [CustomerID], [CustomerNumber], [CustomerName], [CustomerType], [ChargeFee], [ChargeCash], [ChargeBalance], [ChargeOther], [RealFee], [LastAdjust], [Adjust], [Remark], [PrintCount], [Creator], [CreateTime]) VALUES (7, N'0000000000000007', 7, 1, N'1', N'SHUBHAM', N'GENERAL', CAST(3000.0000 AS Decimal(14, 4)), CAST(3000.0000 AS Decimal(12, 4)), CAST(0.0000 AS Decimal(12, 4)), CAST(0.0000 AS Decimal(12, 4)), CAST(3000.0000 AS Decimal(14, 4)), CAST(0.0000 AS Decimal(14, 4)), CAST(0.0000 AS Decimal(14, 4)), NULL, 0, N'admin', CAST(0x0000AA5300E8254C AS DateTime))
INSERT [dbo].[BillInfo] ([BillID], [BillNumber], [UserCostID], [CustomerID], [CustomerNumber], [CustomerName], [CustomerType], [ChargeFee], [ChargeCash], [ChargeBalance], [ChargeOther], [RealFee], [LastAdjust], [Adjust], [Remark], [PrintCount], [Creator], [CreateTime]) VALUES (8, N'0000000000000008', 8, 1, N'1', N'SHUBHAM', N'GENERAL', CAST(-3000.0000 AS Decimal(14, 4)), CAST(-3000.0000 AS Decimal(12, 4)), CAST(0.0000 AS Decimal(12, 4)), CAST(0.0000 AS Decimal(12, 4)), CAST(-3000.0000 AS Decimal(14, 4)), CAST(0.0000 AS Decimal(14, 4)), CAST(0.0000 AS Decimal(14, 4)), NULL, 0, N'admin', CAST(0x0000AA5300E98860 AS DateTime))
INSERT [dbo].[BillInfo] ([BillID], [BillNumber], [UserCostID], [CustomerID], [CustomerNumber], [CustomerName], [CustomerType], [ChargeFee], [ChargeCash], [ChargeBalance], [ChargeOther], [RealFee], [LastAdjust], [Adjust], [Remark], [PrintCount], [Creator], [CreateTime]) VALUES (9, N'0000000000000009', 9, 1, N'1', N'SHUBHAM', N'GENERAL', CAST(3000.0000 AS Decimal(14, 4)), CAST(3000.0000 AS Decimal(12, 4)), CAST(0.0000 AS Decimal(12, 4)), CAST(0.0000 AS Decimal(12, 4)), CAST(3000.0000 AS Decimal(14, 4)), CAST(0.0000 AS Decimal(14, 4)), CAST(0.0000 AS Decimal(14, 4)), NULL, 0, N'admin', CAST(0x0000AA5300E99D78 AS DateTime))
INSERT [dbo].[BillInfo] ([BillID], [BillNumber], [UserCostID], [CustomerID], [CustomerNumber], [CustomerName], [CustomerType], [ChargeFee], [ChargeCash], [ChargeBalance], [ChargeOther], [RealFee], [LastAdjust], [Adjust], [Remark], [PrintCount], [Creator], [CreateTime]) VALUES (10, N'0000000000000010', 10, 1, N'1', N'SHUBHAM', N'GENERAL', CAST(-3000.0000 AS Decimal(14, 4)), CAST(-3000.0000 AS Decimal(12, 4)), CAST(0.0000 AS Decimal(12, 4)), CAST(0.0000 AS Decimal(12, 4)), CAST(-3000.0000 AS Decimal(14, 4)), CAST(0.0000 AS Decimal(14, 4)), CAST(0.0000 AS Decimal(14, 4)), NULL, 0, N'admin', CAST(0x0000AA5300EB7364 AS DateTime))
INSERT [dbo].[BillInfo] ([BillID], [BillNumber], [UserCostID], [CustomerID], [CustomerNumber], [CustomerName], [CustomerType], [ChargeFee], [ChargeCash], [ChargeBalance], [ChargeOther], [RealFee], [LastAdjust], [Adjust], [Remark], [PrintCount], [Creator], [CreateTime]) VALUES (11, N'0000000000000011', 11, 2, N'2', N'SHUBHAM', N'GENERAL', CAST(4450.0000 AS Decimal(14, 4)), CAST(4450.0000 AS Decimal(12, 4)), CAST(0.0000 AS Decimal(12, 4)), CAST(0.0000 AS Decimal(12, 4)), CAST(4450.0000 AS Decimal(14, 4)), CAST(0.0000 AS Decimal(14, 4)), CAST(0.0000 AS Decimal(14, 4)), NULL, 0, N'admin', CAST(0x0000AA5300F3DFA4 AS DateTime))
INSERT [dbo].[BillInfo] ([BillID], [BillNumber], [UserCostID], [CustomerID], [CustomerNumber], [CustomerName], [CustomerType], [ChargeFee], [ChargeCash], [ChargeBalance], [ChargeOther], [RealFee], [LastAdjust], [Adjust], [Remark], [PrintCount], [Creator], [CreateTime]) VALUES (12, N'0000000000000012', 12, 2, N'2', N'SHUBHAM', N'GENERAL', CAST(-3000.0000 AS Decimal(14, 4)), CAST(-3000.0000 AS Decimal(12, 4)), CAST(0.0000 AS Decimal(12, 4)), CAST(0.0000 AS Decimal(12, 4)), CAST(-3000.0000 AS Decimal(14, 4)), CAST(0.0000 AS Decimal(14, 4)), CAST(0.0000 AS Decimal(14, 4)), NULL, 0, N'admin', CAST(0x0000AA5300F403F8 AS DateTime))
INSERT [dbo].[BillInfo] ([BillID], [BillNumber], [UserCostID], [CustomerID], [CustomerNumber], [CustomerName], [CustomerType], [ChargeFee], [ChargeCash], [ChargeBalance], [ChargeOther], [RealFee], [LastAdjust], [Adjust], [Remark], [PrintCount], [Creator], [CreateTime]) VALUES (13, N'0000000000000013', 13, 2, N'2', N'SHUBHAM', N'GENERAL', CAST(3000.0000 AS Decimal(14, 4)), CAST(3000.0000 AS Decimal(12, 4)), CAST(0.0000 AS Decimal(12, 4)), CAST(0.0000 AS Decimal(12, 4)), CAST(3000.0000 AS Decimal(14, 4)), CAST(0.0000 AS Decimal(14, 4)), CAST(0.0000 AS Decimal(14, 4)), NULL, 0, N'admin', CAST(0x0000AA5300F41EEC AS DateTime))
INSERT [dbo].[BillInfo] ([BillID], [BillNumber], [UserCostID], [CustomerID], [CustomerNumber], [CustomerName], [CustomerType], [ChargeFee], [ChargeCash], [ChargeBalance], [ChargeOther], [RealFee], [LastAdjust], [Adjust], [Remark], [PrintCount], [Creator], [CreateTime]) VALUES (14, N'0000000000000014', 14, 2, N'2', N'SHUBHAM', N'GENERAL', CAST(-3000.0000 AS Decimal(14, 4)), CAST(-3000.0000 AS Decimal(12, 4)), CAST(0.0000 AS Decimal(12, 4)), CAST(0.0000 AS Decimal(12, 4)), CAST(-3000.0000 AS Decimal(14, 4)), CAST(0.0000 AS Decimal(14, 4)), CAST(0.0000 AS Decimal(14, 4)), NULL, 0, N'admin', CAST(0x0000AA5300FAC224 AS DateTime))
INSERT [dbo].[BillInfo] ([BillID], [BillNumber], [UserCostID], [CustomerID], [CustomerNumber], [CustomerName], [CustomerType], [ChargeFee], [ChargeCash], [ChargeBalance], [ChargeOther], [RealFee], [LastAdjust], [Adjust], [Remark], [PrintCount], [Creator], [CreateTime]) VALUES (15, N'0000000000000015', 15, 2, N'2', N'SHUBHAM', N'GENERAL', CAST(3000.0000 AS Decimal(14, 4)), CAST(3000.0000 AS Decimal(12, 4)), CAST(0.0000 AS Decimal(12, 4)), CAST(0.0000 AS Decimal(12, 4)), CAST(3000.0000 AS Decimal(14, 4)), CAST(0.0000 AS Decimal(14, 4)), CAST(0.0000 AS Decimal(14, 4)), NULL, 0, N'admin', CAST(0x0000AA5300FB56F8 AS DateTime))
SET IDENTITY_INSERT [dbo].[BillInfo] OFF
INSERT [dbo].[CAInstance] ([ID], [Name], [IPAddress], [Port], [Remark], [Active], [SortSetting]) VALUES (1, N'CAS4', N'127.0.0.1', 4500, N'', 0, 2)
INSERT [dbo].[CAInstance] ([ID], [Name], [IPAddress], [Port], [Remark], [Active], [SortSetting]) VALUES (2, N'CAS5', N'127.0.0.1', 4501, N'', 0, 3)
INSERT [dbo].[CAInstance] ([ID], [Name], [IPAddress], [Port], [Remark], [Active], [SortSetting]) VALUES (3, N'CAS6', N'127.0.0.1', 4502, N'', 1, 4)
INSERT [dbo].[CAInstance] ([ID], [Name], [IPAddress], [Port], [Remark], [Active], [SortSetting]) VALUES (4, N'CAS3', N'127.0.0.1', 4503, N'', 0, 1)
SET IDENTITY_INSERT [dbo].[CertificateType] ON 

INSERT [dbo].[CertificateType] ([CertificateTypeID], [CertificateName], [Active], [Creator], [CreateTime], [LastEditor], [LastEditTime]) VALUES (1, N'ID', 1, N'admin', CAST(0x0000AA5300E11068 AS DateTime), N'admin', CAST(0x0000AA5300E11068 AS DateTime))
SET IDENTITY_INSERT [dbo].[CertificateType] OFF
SET IDENTITY_INSERT [dbo].[ConditionAddress] ON 

INSERT [dbo].[ConditionAddress] ([ID], [ConditionType], [CASVersion], [CASID], [OperatorName], [StartTime], [EndTime], [DepartmentID], [Active], [Creator], [CreateTime], [LastEditor], [LastEditTime]) VALUES (1, 14, 3, 4611686018427387908, N'Administrator', CAST(0x0000AA5300000000 AS DateTime), CAST(0x0000AA5A00000000 AS DateTime), 1, 0, N'admin', CAST(0x0000AA5300F4E87C AS DateTime), N'admin', CAST(0x0000AA5300F51504 AS DateTime))
INSERT [dbo].[ConditionAddress] ([ID], [ConditionType], [CASVersion], [CASID], [OperatorName], [StartTime], [EndTime], [DepartmentID], [Active], [Creator], [CreateTime], [LastEditor], [LastEditTime]) VALUES (2, 13, 3, 4611686018427387909, N'Administrator', CAST(0x0000AA5300000000 AS DateTime), CAST(0x0000AA5A00000000 AS DateTime), 1, 0, N'admin', CAST(0x0000AA5300F57FA8 AS DateTime), N'admin', CAST(0x0000AA5300F58EE4 AS DateTime))
INSERT [dbo].[ConditionAddress] ([ID], [ConditionType], [CASVersion], [CASID], [OperatorName], [StartTime], [EndTime], [DepartmentID], [Active], [Creator], [CreateTime], [LastEditor], [LastEditTime]) VALUES (3, 13, 3, 4611686018427387910, N'Administrator', CAST(0x0000AA5300000000 AS DateTime), CAST(0x0000AA5A00000000 AS DateTime), 1, 0, N'admin', CAST(0x0000AA5300F5AD5C AS DateTime), N'admin', CAST(0x0000AA5300F5D084 AS DateTime))
INSERT [dbo].[ConditionAddress] ([ID], [ConditionType], [CASVersion], [CASID], [OperatorName], [StartTime], [EndTime], [DepartmentID], [Active], [Creator], [CreateTime], [LastEditor], [LastEditTime]) VALUES (4, 15, 3, 4611686018427387911, N'Administrator', CAST(0x0000AA5300000000 AS DateTime), CAST(0x0000AA5A00000000 AS DateTime), 1, 0, N'admin', CAST(0x0000AA5300F60798 AS DateTime), N'admin', CAST(0x0000AA5300F62160 AS DateTime))
INSERT [dbo].[ConditionAddress] ([ID], [ConditionType], [CASVersion], [CASID], [OperatorName], [StartTime], [EndTime], [DepartmentID], [Active], [Creator], [CreateTime], [LastEditor], [LastEditTime]) VALUES (5, 5, 3, 4611686018427387912, N'Administrator', CAST(0x0000AA5300000000 AS DateTime), CAST(0x0000AA5A00000000 AS DateTime), 1, 0, N'admin', CAST(0x0000AA5300F66300 AS DateTime), N'admin', CAST(0x0000AA5300F676EC AS DateTime))
INSERT [dbo].[ConditionAddress] ([ID], [ConditionType], [CASVersion], [CASID], [OperatorName], [StartTime], [EndTime], [DepartmentID], [Active], [Creator], [CreateTime], [LastEditor], [LastEditTime]) VALUES (6, 5, 3, 4611686018427387913, N'Administrator', CAST(0x0000AA5300000000 AS DateTime), CAST(0x0000AA5A00000000 AS DateTime), 1, 0, N'admin', CAST(0x0000AA5300F6BC10 AS DateTime), N'admin', CAST(0x0000AA5300F6CB4C AS DateTime))
SET IDENTITY_INSERT [dbo].[ConditionAddress] OFF
SET IDENTITY_INSERT [dbo].[ConditionOSD] ON 

INSERT [dbo].[ConditionOSD] ([ID], [ConditionID], [OSDContent], [DisplayCount], [Priority], [Position], [Font_Size], [Font_Type], [Font_Color], [Background_Color]) VALUES (1, 5, N'HYYY ', 50, 0, 0, 20, 0, -1, -8388480)
INSERT [dbo].[ConditionOSD] ([ID], [ConditionID], [OSDContent], [DisplayCount], [Priority], [Position], [Font_Size], [Font_Type], [Font_Color], [Background_Color]) VALUES (2, 6, N'HYY', 50, 0, 3, 22, 0, -1, -8388480)
SET IDENTITY_INSERT [dbo].[ConditionOSD] OFF
SET IDENTITY_INSERT [dbo].[ConditionWithKey] ON 

INSERT [dbo].[ConditionWithKey] ([ID], [ConditionID], [Ordering], [IsAnd], [ConditionByType], [OperateType], [Val]) VALUES (1, 1, 0, 128, 48, 115, N'10')
INSERT [dbo].[ConditionWithKey] ([ID], [ConditionID], [Ordering], [IsAnd], [ConditionByType], [OperateType], [Val]) VALUES (2, 2, 0, 128, 48, 115, N'10')
INSERT [dbo].[ConditionWithKey] ([ID], [ConditionID], [Ordering], [IsAnd], [ConditionByType], [OperateType], [Val]) VALUES (3, 3, 0, 128, 48, 115, N'10')
INSERT [dbo].[ConditionWithKey] ([ID], [ConditionID], [Ordering], [IsAnd], [ConditionByType], [OperateType], [Val]) VALUES (4, 4, 0, 128, 48, 115, N'10')
INSERT [dbo].[ConditionWithKey] ([ID], [ConditionID], [Ordering], [IsAnd], [ConditionByType], [OperateType], [Val]) VALUES (5, 5, 0, 128, 48, 115, N'10')
INSERT [dbo].[ConditionWithKey] ([ID], [ConditionID], [Ordering], [IsAnd], [ConditionByType], [OperateType], [Val]) VALUES (6, 6, 0, 128, 48, 115, N'10')
SET IDENTITY_INSERT [dbo].[ConditionWithKey] OFF
SET IDENTITY_INSERT [dbo].[ConditionWithPrograms] ON 

INSERT [dbo].[ConditionWithPrograms] ([ID], [ConditionID], [ProgramID]) VALUES (1, 1, 1)
INSERT [dbo].[ConditionWithPrograms] ([ID], [ConditionID], [ProgramID]) VALUES (2, 4, 1)
SET IDENTITY_INSERT [dbo].[ConditionWithPrograms] OFF
SET IDENTITY_INSERT [dbo].[CustomerInfo] ON 

INSERT [dbo].[CustomerInfo] ([CustomerID], [CustomerNumber], [CustomerName], [CertificateTypeID], [CertificateID], [TelNumber], [MobilePhoneNumber], [RegionID], [Address], [CustTypeID], [MasterDepartmentID], [DepartmentID], [Remark], [BillingAddress], [EmailID], [SubscriptionContractNumber], [balance], [Adjust], [Status], [Active], [NewAccountTime], [Creator], [CreateTime], [LastEditor], [LastEditTime]) VALUES (1, N'1', N'SHUBHAM', 1, N'259099733934', NULL, N'8866887669', 2, N'XXXXXXXXX', 1, 1, 1, NULL, NULL, NULL, NULL, CAST(0.0000 AS Decimal(12, 4)), CAST(0.0000 AS Decimal(12, 4)), 2, 1, CAST(0x0000AA5300E57A18 AS DateTime), N'admin', CAST(0x0000AA5300E57A18 AS DateTime), N'admin', CAST(0x0000AA5300E57A18 AS DateTime))
INSERT [dbo].[CustomerInfo] ([CustomerID], [CustomerNumber], [CustomerName], [CertificateTypeID], [CertificateID], [TelNumber], [MobilePhoneNumber], [RegionID], [Address], [CustTypeID], [MasterDepartmentID], [DepartmentID], [Remark], [BillingAddress], [EmailID], [SubscriptionContractNumber], [balance], [Adjust], [Status], [Active], [NewAccountTime], [Creator], [CreateTime], [LastEditor], [LastEditTime]) VALUES (2, N'2', N'SHUBHAM', 1, N'259099733934', NULL, N'8866887669', 2, N'XXXXXXX', 1, 1, 1, NULL, NULL, NULL, NULL, CAST(0.0000 AS Decimal(12, 4)), CAST(0.0000 AS Decimal(12, 4)), 1, 1, CAST(0x0000AA5300F23898 AS DateTime), N'admin', CAST(0x0000AA5300F23898 AS DateTime), N'admin', CAST(0x0000AA5300F23898 AS DateTime))
SET IDENTITY_INSERT [dbo].[CustomerInfo] OFF
SET IDENTITY_INSERT [dbo].[CustomerInit] ON 

INSERT [dbo].[CustomerInit] ([ID], [UserCostID], [CustomerID], [OrderFeePackageID], [PriceID], [Price], [PreferentialID], [Preferential], [OriginalFee], [RealFee], [OperateType], [Status], [BackOrderID], [Remark], [Creator], [CreateTime], [LastEditor], [LastEditTime]) VALUES (1, 1, 1, NULL, 1, CAST(0.0000 AS Decimal(12, 4)), NULL, CAST(0.0000 AS Decimal(12, 4)), CAST(0.0000 AS Decimal(12, 4)), CAST(0.0000 AS Decimal(12, 4)), 1, 1, NULL, NULL, N'admin', CAST(0x0000AA5300E57A18 AS DateTime), N'admin', CAST(0x0000AA5300E57A18 AS DateTime))
INSERT [dbo].[CustomerInit] ([ID], [UserCostID], [CustomerID], [OrderFeePackageID], [PriceID], [Price], [PreferentialID], [Preferential], [OriginalFee], [RealFee], [OperateType], [Status], [BackOrderID], [Remark], [Creator], [CreateTime], [LastEditor], [LastEditTime]) VALUES (2, 11, 2, NULL, 1, CAST(0.0000 AS Decimal(12, 4)), NULL, CAST(0.0000 AS Decimal(12, 4)), CAST(0.0000 AS Decimal(12, 4)), CAST(0.0000 AS Decimal(12, 4)), 1, 1, NULL, NULL, N'admin', CAST(0x0000AA5300F23898 AS DateTime), N'admin', CAST(0x0000AA5300F23898 AS DateTime))
SET IDENTITY_INSERT [dbo].[CustomerInit] OFF
SET IDENTITY_INSERT [dbo].[CustTypeInfo] ON 

INSERT [dbo].[CustTypeInfo] ([CustTypeID], [CustTypeName], [DepartmentID], [Active], [Creator], [CreateTime], [LastEditor], [LastEditTime]) VALUES (1, N'GENERAL', 1, 1, N'admin', CAST(0x0000AA5300E10834 AS DateTime), N'admin', CAST(0x0000AA5300E10834 AS DateTime))
SET IDENTITY_INSERT [dbo].[CustTypeInfo] OFF
SET IDENTITY_INSERT [dbo].[Department] ON 

INSERT [dbo].[Department] ([DepartmentID], [DepartmentName], [ParentDepartmentID], [DepartmentType], [Layer], [Active], [Creator], [CreateTime], [LastEditor], [LastEditTime]) VALUES (1, N'MSO', NULL, 0, N'0001000000000000', 1, N'admin', CAST(0x0000AA5300DFDB1F AS DateTime), N'admin', CAST(0x0000AA5300DFDB1F AS DateTime))
SET IDENTITY_INSERT [dbo].[Department] OFF
INSERT [dbo].[Department_Region_Relation] ([DepartmentID], [RegionID]) VALUES (1, 1)
SET IDENTITY_INSERT [dbo].[ECMGFinger] ON 

INSERT [dbo].[ECMGFinger] ([ID], [ConditionID], [IsForce]) VALUES (1, 1, 0)
SET IDENTITY_INSERT [dbo].[ECMGFinger] OFF
SET IDENTITY_INSERT [dbo].[EMMGFinger] ON 

INSERT [dbo].[EMMGFinger] ([ID], [ConditionID], [ShowTime], [StopTime], [Font_Size], [Font_Type], [ColorType], [Font_Color], [Background_Color], [Positions], [PositionX], [PositionY], [OvertFlag], [IsDisplayBackGround], [IsDisplaySTBID]) VALUES (1, 2, 1, 0, 24, 0, 3, -1, -16777216, 4, 0, 0, 1, 1, 1)
INSERT [dbo].[EMMGFinger] ([ID], [ConditionID], [ShowTime], [StopTime], [Font_Size], [Font_Type], [ColorType], [Font_Color], [Background_Color], [Positions], [PositionX], [PositionY], [OvertFlag], [IsDisplayBackGround], [IsDisplaySTBID]) VALUES (2, 3, 1, 0, 36, 0, 3, -1, -16776961, 4, 0, 0, 0, 1, 1)
SET IDENTITY_INSERT [dbo].[EMMGFinger] OFF
SET IDENTITY_INSERT [dbo].[ForceOSD] ON 

INSERT [dbo].[ForceOSD] ([ID], [ConditionID], [Font_Size], [Font_Type], [ColorType], [Font_Color], [Background_Color], [OSDContent], [Ratio], [ShowTime], [StopTime], [Clarity], [IsForceOSD]) VALUES (1, 4, 22, 0, 3, -1, -8388480, N'HYYY', 80, 50, 10, 100, 1)
SET IDENTITY_INSERT [dbo].[ForceOSD] OFF
SET IDENTITY_INSERT [dbo].[Function_Permit_Relation] ON 

INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (1, 1, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (2, 2, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (3, 2, 21)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (4, 2, 28)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (5, 3, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (6, 3, 2)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (7, 3, 3)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (8, 3, 4)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (9, 3, 20)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (10, 4, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (11, 4, 2)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (12, 4, 3)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (13, 4, 4)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (14, 5, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (15, 6, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (16, 6, 2)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (17, 6, 3)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (18, 6, 4)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (19, 7, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (20, 7, 2)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (21, 7, 3)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (22, 7, 4)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (23, 8, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (24, 8, 2)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (25, 8, 3)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (26, 8, 4)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (27, 9, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (28, 9, 2)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (29, 9, 3)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (30, 9, 4)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (31, 10, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (32, 10, 2)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (33, 10, 3)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (34, 10, 4)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (35, 10, 6)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (36, 10, 25)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (37, 11, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (38, 11, 2)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (39, 11, 3)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (40, 11, 4)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (41, 11, 16)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (42, 12, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (43, 13, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (44, 13, 3)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (45, 14, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (46, 14, 2)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (47, 14, 3)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (48, 14, 4)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (49, 15, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (50, 16, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (51, 17, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (52, 17, 2)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (53, 17, 3)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (54, 17, 4)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (55, 17, 7)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (56, 17, 17)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (57, 18, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (58, 18, 2)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (59, 18, 3)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (60, 18, 4)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (61, 18, 7)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (62, 18, 17)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (63, 19, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (64, 20, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (65, 20, 2)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (66, 20, 3)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (67, 20, 4)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (68, 20, 7)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (69, 20, 8)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (70, 21, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (71, 21, 2)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (72, 21, 3)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (73, 21, 4)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (74, 22, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (75, 23, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (76, 24, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (77, 24, 2)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (78, 24, 3)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (79, 24, 4)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (80, 24, 5)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (81, 24, 20)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (82, 25, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (83, 25, 2)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (84, 25, 3)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (85, 25, 4)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (86, 25, 5)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (87, 25, 20)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (88, 26, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (89, 26, 2)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (90, 26, 3)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (91, 26, 4)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (92, 26, 5)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (93, 26, 20)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (94, 27, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (95, 27, 2)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (96, 27, 3)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (97, 27, 4)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (98, 27, 5)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (99, 27, 20)
GO
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (100, 28, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (101, 28, 2)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (102, 28, 3)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (103, 28, 4)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (104, 28, 5)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (105, 28, 20)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (106, 29, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (107, 29, 2)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (108, 29, 3)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (109, 29, 4)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (110, 29, 5)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (111, 29, 20)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (112, 30, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (113, 30, 2)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (114, 30, 3)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (115, 30, 4)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (116, 30, 5)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (117, 31, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (118, 32, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (119, 33, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (120, 33, 9)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (121, 33, 10)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (122, 33, 11)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (123, 34, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (124, 34, 21)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (125, 35, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (126, 35, 21)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (127, 36, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (128, 36, 21)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (129, 37, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (130, 37, 21)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (131, 38, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (132, 38, 21)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (133, 39, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (134, 39, 21)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (135, 40, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (136, 40, 21)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (137, 40, 26)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (138, 41, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (139, 41, 21)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (140, 42, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (141, 42, 21)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (142, 43, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (143, 43, 21)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (144, 44, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (145, 44, 12)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (146, 44, 13)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (147, 45, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (148, 45, 21)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (149, 46, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (150, 47, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (151, 47, 14)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (152, 47, 15)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (153, 48, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (154, 48, 21)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (155, 49, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (156, 49, 21)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (157, 50, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (158, 50, 21)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (159, 51, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (160, 51, 22)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (161, 51, 23)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (162, 51, 24)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (163, 52, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (164, 52, 22)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (165, 52, 23)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (166, 53, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (167, 53, 12)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (168, 54, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (169, 55, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (170, 56, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (171, 56, 21)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (172, 57, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (173, 57, 21)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (174, 58, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (175, 58, 21)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (176, 59, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (177, 60, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (178, 60, 21)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (179, 61, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (180, 61, 2)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (181, 61, 4)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (182, 62, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (183, 62, 2)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (184, 62, 4)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (185, 63, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (186, 63, 2)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (187, 63, 4)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (188, 64, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (189, 65, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (190, 66, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (191, 66, 2)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (192, 66, 4)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (193, 67, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (194, 67, 2)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (195, 67, 4)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (196, 68, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (197, 68, 21)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (198, 69, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (199, 69, 2)
GO
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (200, 69, 4)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (201, 70, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (202, 70, 2)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (203, 70, 4)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (204, 71, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (205, 71, 2)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (206, 71, 4)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (207, 72, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (208, 72, 2)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (209, 72, 4)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (210, 73, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (211, 73, 2)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (212, 73, 4)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (213, 74, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (214, 74, 2)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (215, 74, 4)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (216, 75, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (217, 75, 2)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (218, 75, 4)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (219, 76, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (220, 76, 2)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (221, 76, 4)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (222, 77, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (223, 77, 2)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (224, 77, 4)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (225, 78, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (226, 78, 2)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (227, 78, 4)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (228, 79, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (229, 79, 2)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (230, 79, 4)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (231, 80, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (232, 81, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (233, 81, 21)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (234, 82, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (235, 82, 2)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (236, 82, 4)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (237, 83, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (238, 83, 2)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (239, 83, 4)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (240, 84, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (241, 84, 2)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (242, 84, 4)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (243, 85, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (244, 85, 2)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (245, 85, 4)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (246, 86, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (247, 86, 2)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (248, 86, 4)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (249, 87, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (250, 87, 2)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (251, 87, 4)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (252, 88, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (253, 88, 2)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (254, 88, 4)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (255, 89, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (256, 89, 2)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (257, 89, 4)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (258, 90, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (259, 90, 2)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (260, 90, 4)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (261, 91, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (262, 91, 2)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (263, 91, 4)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (264, 92, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (265, 92, 2)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (266, 92, 4)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (267, 93, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (268, 93, 2)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (269, 93, 4)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (270, 94, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (271, 94, 2)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (272, 94, 4)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (273, 95, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (274, 95, 2)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (275, 95, 4)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (276, 96, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (277, 97, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (278, 98, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (279, 99, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (280, 100, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (281, 101, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (282, 102, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (283, 103, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (284, 104, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (285, 105, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (286, 106, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (287, 107, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (288, 108, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (289, 109, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (290, 109, 9)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (291, 111, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (292, 111, 21)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (293, 112, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (294, 112, 27)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (295, 113, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (296, 113, 21)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (297, 114, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (298, 115, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (299, 115, 21)
GO
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (300, 116, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (301, 117, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (302, 117, 21)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (303, 118, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (304, 118, 21)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (305, 119, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (306, 119, 21)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (307, 120, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (308, 120, 21)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (309, 121, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (310, 122, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (311, 123, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (312, 123, 21)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (313, 124, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (314, 124, 21)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (315, 125, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (316, 125, 21)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (317, 126, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (318, 127, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (319, 127, 7)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (320, 127, 21)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (321, 127, 23)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (322, 128, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (323, 129, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (324, 130, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (325, 131, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (326, 132, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (327, 133, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (328, 134, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (329, 135, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (330, 136, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (331, 137, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (332, 138, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (333, 139, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (334, 140, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (335, 141, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (336, 142, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (337, 143, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (338, 144, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (339, 145, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (340, 146, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (341, 147, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (342, 148, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (343, 149, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (344, 150, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (345, 150, 2)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (346, 150, 3)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (347, 150, 4)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (348, 150, 21)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (349, 151, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (350, 151, 2)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (351, 151, 21)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (352, 152, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (353, 153, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (354, 154, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (355, 155, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (356, 155, 2)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (357, 155, 21)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (358, 156, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (359, 156, 2)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (360, 156, 21)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (361, 157, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (362, 158, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (363, 158, 21)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (364, 159, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (365, 160, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (366, 161, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (367, 162, 1)
INSERT [dbo].[Function_Permit_Relation] ([ID], [FunctionID], [PermitID]) VALUES (368, 163, 1)
SET IDENTITY_INSERT [dbo].[Function_Permit_Relation] OFF
SET IDENTITY_INSERT [dbo].[GroupInfo] ON 

INSERT [dbo].[GroupInfo] ([GroupID], [GroupName], [DepartmentID], [Status], [Creator], [CreateTime], [LastEditor], [LastEditTime], [IsPublic]) VALUES (1, N'administrators', 1, 1, N'system', CAST(0x0000AA5300DFDB21 AS DateTime), N'system', CAST(0x0000AA5300DFDB21 AS DateTime), 0)
SET IDENTITY_INSERT [dbo].[GroupInfo] OFF
SET IDENTITY_INSERT [dbo].[ICCardInfo] ON 

INSERT [dbo].[ICCardInfo] ([ID], [InternalNumber], [ExternalNumber], [ParentICTableID], [MatchFlag], [Priority], [UnlockVersion], [CustomerID], [ModelNumber], [RegionID], [DepartmentID], [CurrentFeeModel], [NextFeeModel], [Status], [GroupID], [Active], [Creator], [CreateTime], [LastEditor], [LastEditTime], [FingerPrint], [AreaLock]) VALUES (1, 796, N'8778788000007966', NULL, 0, 0, 0, NULL, 1, NULL, 1, 0, 0, 3, NULL, 0, N'admin', CAST(0x0000AA5300E39748 AS DateTime), N'admin', CAST(0x0000AA5300EB9EC0 AS DateTime), 0, 0)
INSERT [dbo].[ICCardInfo] ([ID], [InternalNumber], [ExternalNumber], [ParentICTableID], [MatchFlag], [Priority], [UnlockVersion], [CustomerID], [ModelNumber], [RegionID], [DepartmentID], [CurrentFeeModel], [NextFeeModel], [Status], [GroupID], [Active], [Creator], [CreateTime], [LastEditor], [LastEditTime], [FingerPrint], [AreaLock]) VALUES (2, 796, N'8778788000007966', NULL, 0, 0, 0, NULL, 1, NULL, 1, 0, 0, 3, NULL, 0, N'admin', CAST(0x0000AA5300EB9EC0 AS DateTime), N'admin', CAST(0x0000AA5300EBF578 AS DateTime), 0, 0)
INSERT [dbo].[ICCardInfo] ([ID], [InternalNumber], [ExternalNumber], [ParentICTableID], [MatchFlag], [Priority], [UnlockVersion], [CustomerID], [ModelNumber], [RegionID], [DepartmentID], [CurrentFeeModel], [NextFeeModel], [Status], [GroupID], [Active], [Creator], [CreateTime], [LastEditor], [LastEditTime], [FingerPrint], [AreaLock]) VALUES (3, 796, N'8778788000007966', NULL, 1, 0, 0, 2, 1, 2, 1, 0, 0, 1, 1, 1, N'admin', CAST(0x0000AA5300F20760 AS DateTime), N'admin', CAST(0x0000AA5300F83A18 AS DateTime), 1, 0)
SET IDENTITY_INSERT [dbo].[ICCardInfo] OFF
SET IDENTITY_INSERT [dbo].[ICStatusChange] ON 

INSERT [dbo].[ICStatusChange] ([ID], [ICTableID], [InternalNumber], [STBID], [STBRealNumber], [ICStatus], [CustomerID], [DepartmentID], [Creator], [CreateTime], [Remark]) VALUES (1, 1, 796, 0, NULL, 3, NULL, 1, N'admin', CAST(0x0000AA5300E39748 AS DateTime), N'Function:IC Card Management[17]')
INSERT [dbo].[ICStatusChange] ([ID], [ICTableID], [InternalNumber], [STBID], [STBRealNumber], [ICStatus], [CustomerID], [DepartmentID], [Creator], [CreateTime], [Remark]) VALUES (2, 1, 796, 0, NULL, 1, 1, 1, N'admin', CAST(0x0000AA5300E586FC AS DateTime), N'Function:Oder IC[34]')
INSERT [dbo].[ICStatusChange] ([ID], [ICTableID], [InternalNumber], [STBID], [STBRealNumber], [ICStatus], [CustomerID], [DepartmentID], [Creator], [CreateTime], [Remark]) VALUES (3, 1, 796, 0, NULL, 1, 1, 1, N'admin', CAST(0x0000AA5300E5A1F0 AS DateTime), N'Function:IC STB Pairing[51]')
INSERT [dbo].[ICStatusChange] ([ID], [ICTableID], [InternalNumber], [STBID], [STBRealNumber], [ICStatus], [CustomerID], [DepartmentID], [Creator], [CreateTime], [Remark]) VALUES (4, 1, 796, 1, N'8778788000007966', 1, 1, 1, N'admin', CAST(0x0000AA5300E5A1F0 AS DateTime), N'Function:IC STB Pairing[51]')
INSERT [dbo].[ICStatusChange] ([ID], [ICTableID], [InternalNumber], [STBID], [STBRealNumber], [ICStatus], [CustomerID], [DepartmentID], [Creator], [CreateTime], [Remark]) VALUES (5, 1, 796, 1, N'8778788000007966', 1, 1, 1, N'admin', CAST(0x0000AA5300E5C194 AS DateTime), N'Function:IC STB Pairing[51]')
INSERT [dbo].[ICStatusChange] ([ID], [ICTableID], [InternalNumber], [STBID], [STBRealNumber], [ICStatus], [CustomerID], [DepartmentID], [Creator], [CreateTime], [Remark]) VALUES (6, 1, 796, 1, N'8778788000007966', 1, 1, 1, N'admin', CAST(0x0000AA5300E5C3EC AS DateTime), N'Function:IC STB Pairing[51]')
INSERT [dbo].[ICStatusChange] ([ID], [ICTableID], [InternalNumber], [STBID], [STBRealNumber], [ICStatus], [CustomerID], [DepartmentID], [Creator], [CreateTime], [Remark]) VALUES (7, 1, 796, 1, N'8778788000007966', 1, 1, 1, N'admin', CAST(0x0000AA5300E87E5C AS DateTime), N'Function:IC STB Pairing[51]')
INSERT [dbo].[ICStatusChange] ([ID], [ICTableID], [InternalNumber], [STBID], [STBRealNumber], [ICStatus], [CustomerID], [DepartmentID], [Creator], [CreateTime], [Remark]) VALUES (9, 1, 796, 0, NULL, 1, 1, 1, N'admin', CAST(0x0000AA5300E8D898 AS DateTime), N'Function:IC STB Pairing[51]')
INSERT [dbo].[ICStatusChange] ([ID], [ICTableID], [InternalNumber], [STBID], [STBRealNumber], [ICStatus], [CustomerID], [DepartmentID], [Creator], [CreateTime], [Remark]) VALUES (10, 1, 796, 1, N'8778788000007966', 1, 1, 1, N'admin', CAST(0x0000AA5300E8D898 AS DateTime), N'Function:IC STB Pairing[51]')
INSERT [dbo].[ICStatusChange] ([ID], [ICTableID], [InternalNumber], [STBID], [STBRealNumber], [ICStatus], [CustomerID], [DepartmentID], [Creator], [CreateTime], [Remark]) VALUES (11, 1, 796, 1, N'8778788000007966', 1, 1, 1, N'admin', CAST(0x0000AA5300E8DD48 AS DateTime), N'Function:IC STB Pairing[51]')
INSERT [dbo].[ICStatusChange] ([ID], [ICTableID], [InternalNumber], [STBID], [STBRealNumber], [ICStatus], [CustomerID], [DepartmentID], [Creator], [CreateTime], [Remark]) VALUES (12, 1, 796, 0, NULL, 1, 1, 1, N'admin', CAST(0x0000AA5300E95854 AS DateTime), N'Function:IC STB Pairing[51]')
INSERT [dbo].[ICStatusChange] ([ID], [ICTableID], [InternalNumber], [STBID], [STBRealNumber], [ICStatus], [CustomerID], [DepartmentID], [Creator], [CreateTime], [Remark]) VALUES (13, 1, 796, 1, N'8778788000007966', 1, 1, 1, N'admin', CAST(0x0000AA5300E95854 AS DateTime), N'Function:IC STB Pairing[51]')
INSERT [dbo].[ICStatusChange] ([ID], [ICTableID], [InternalNumber], [STBID], [STBRealNumber], [ICStatus], [CustomerID], [DepartmentID], [Creator], [CreateTime], [Remark]) VALUES (14, 1, 796, 1, N'8778788000007966', 1, 1, 1, N'admin', CAST(0x0000AA5300E95BD8 AS DateTime), N'Function:IC STB Pairing[51]')
INSERT [dbo].[ICStatusChange] ([ID], [ICTableID], [InternalNumber], [STBID], [STBRealNumber], [ICStatus], [CustomerID], [DepartmentID], [Creator], [CreateTime], [Remark]) VALUES (15, 1, 796, 1, N'8778788000007966', 1, 1, 1, N'admin', CAST(0x0000AA5300E95D04 AS DateTime), N'Function:IC STB Pairing[51]')
INSERT [dbo].[ICStatusChange] ([ID], [ICTableID], [InternalNumber], [STBID], [STBRealNumber], [ICStatus], [CustomerID], [DepartmentID], [Creator], [CreateTime], [Remark]) VALUES (16, 1, 796, 1, N'8778788000007966', 1, 1, 1, N'admin', CAST(0x0000AA5300E95D04 AS DateTime), N'Function:IC STB Pairing[51]')
INSERT [dbo].[ICStatusChange] ([ID], [ICTableID], [InternalNumber], [STBID], [STBRealNumber], [ICStatus], [CustomerID], [DepartmentID], [Creator], [CreateTime], [Remark]) VALUES (17, 1, 796, 1, N'8778788000007966', 1, 1, 1, N'admin', CAST(0x0000AA5300E95E30 AS DateTime), N'Function:IC STB Pairing[51]')
INSERT [dbo].[ICStatusChange] ([ID], [ICTableID], [InternalNumber], [STBID], [STBRealNumber], [ICStatus], [CustomerID], [DepartmentID], [Creator], [CreateTime], [Remark]) VALUES (18, 1, 796, 1, N'8778788000007966', 1, 1, 1, N'admin', CAST(0x0000AA5300E95F5C AS DateTime), N'Function:IC STB Pairing[51]')
INSERT [dbo].[ICStatusChange] ([ID], [ICTableID], [InternalNumber], [STBID], [STBRealNumber], [ICStatus], [CustomerID], [DepartmentID], [Creator], [CreateTime], [Remark]) VALUES (19, 1, 796, 1, N'8778788000007966', 1, 1, 1, N'admin', CAST(0x0000AA5300EB8048 AS DateTime), N'Function:IC STB Pairing[51]')
INSERT [dbo].[ICStatusChange] ([ID], [ICTableID], [InternalNumber], [STBID], [STBRealNumber], [ICStatus], [CustomerID], [DepartmentID], [Creator], [CreateTime], [Remark]) VALUES (20, 1, 796, 0, NULL, 0, NULL, 1, N'admin', CAST(0x0000AA5300EB8D2C AS DateTime), N'Function:IC Cancel[124]')
INSERT [dbo].[ICStatusChange] ([ID], [ICTableID], [InternalNumber], [STBID], [STBRealNumber], [ICStatus], [CustomerID], [DepartmentID], [Creator], [CreateTime], [Remark]) VALUES (21, 1, 796, 0, NULL, 3, NULL, 1, N'admin', CAST(0x0000AA5300EB9EC0 AS DateTime), N'Function:IC Card Recycle[56]')
INSERT [dbo].[ICStatusChange] ([ID], [ICTableID], [InternalNumber], [STBID], [STBRealNumber], [ICStatus], [CustomerID], [DepartmentID], [Creator], [CreateTime], [Remark]) VALUES (22, 2, 796, 0, NULL, 3, NULL, 1, N'admin', CAST(0x0000AA5300EB9EC0 AS DateTime), N'Function:IC Card Recycle[56]')
INSERT [dbo].[ICStatusChange] ([ID], [ICTableID], [InternalNumber], [STBID], [STBRealNumber], [ICStatus], [CustomerID], [DepartmentID], [Creator], [CreateTime], [Remark]) VALUES (23, 2, 796, 0, NULL, 3, NULL, 1, N'admin', CAST(0x0000AA5300EBF578 AS DateTime), N'Function:IC Card Management[17]')
INSERT [dbo].[ICStatusChange] ([ID], [ICTableID], [InternalNumber], [STBID], [STBRealNumber], [ICStatus], [CustomerID], [DepartmentID], [Creator], [CreateTime], [Remark]) VALUES (24, 3, 796, 0, NULL, 3, NULL, 1, N'admin', CAST(0x0000AA5300F20760 AS DateTime), N'Function:IC Card Management[17]')
INSERT [dbo].[ICStatusChange] ([ID], [ICTableID], [InternalNumber], [STBID], [STBRealNumber], [ICStatus], [CustomerID], [DepartmentID], [Creator], [CreateTime], [Remark]) VALUES (25, 3, 796, 0, NULL, 1, 2, 1, N'admin', CAST(0x0000AA5300F24900 AS DateTime), N'Function:Oder IC[34]')
INSERT [dbo].[ICStatusChange] ([ID], [ICTableID], [InternalNumber], [STBID], [STBRealNumber], [ICStatus], [CustomerID], [DepartmentID], [Creator], [CreateTime], [Remark]) VALUES (26, 3, 796, 0, NULL, 1, 2, 1, N'admin', CAST(0x0000AA5300F2FD78 AS DateTime), N'Function:IC STB Pairing[51]')
INSERT [dbo].[ICStatusChange] ([ID], [ICTableID], [InternalNumber], [STBID], [STBRealNumber], [ICStatus], [CustomerID], [DepartmentID], [Creator], [CreateTime], [Remark]) VALUES (27, 3, 796, 3, N'8778788000007966', 1, 2, 1, N'admin', CAST(0x0000AA5300F2FD78 AS DateTime), N'Function:IC STB Pairing[51]')
INSERT [dbo].[ICStatusChange] ([ID], [ICTableID], [InternalNumber], [STBID], [STBRealNumber], [ICStatus], [CustomerID], [DepartmentID], [Creator], [CreateTime], [Remark]) VALUES (28, 3, 796, 3, N'8778788000007966', 1, 2, 1, N'admin', CAST(0x0000AA5300F36240 AS DateTime), N'Function:IC STB Pairing[51]')
INSERT [dbo].[ICStatusChange] ([ID], [ICTableID], [InternalNumber], [STBID], [STBRealNumber], [ICStatus], [CustomerID], [DepartmentID], [Creator], [CreateTime], [Remark]) VALUES (29, 3, 796, 3, N'8778788000007966', 1, 2, 1, N'admin', CAST(0x0000AA5300F3636C AS DateTime), N'Function:IC STB Pairing[51]')
INSERT [dbo].[ICStatusChange] ([ID], [ICTableID], [InternalNumber], [STBID], [STBRealNumber], [ICStatus], [CustomerID], [DepartmentID], [Creator], [CreateTime], [Remark]) VALUES (30, 3, 796, 3, N'8778788000007966', 1, 2, 1, N'admin', CAST(0x0000AA5300F3681C AS DateTime), N'Function:IC STB Pairing[51]')
INSERT [dbo].[ICStatusChange] ([ID], [ICTableID], [InternalNumber], [STBID], [STBRealNumber], [ICStatus], [CustomerID], [DepartmentID], [Creator], [CreateTime], [Remark]) VALUES (31, 3, 796, 3, N'8778788000007966', 1, 2, 1, N'admin', CAST(0x0000AA5300F36948 AS DateTime), N'Function:IC STB Pairing[51]')
INSERT [dbo].[ICStatusChange] ([ID], [ICTableID], [InternalNumber], [STBID], [STBRealNumber], [ICStatus], [CustomerID], [DepartmentID], [Creator], [CreateTime], [Remark]) VALUES (32, 3, 796, 3, N'8778788000007966', 1, 2, 1, N'admin', CAST(0x0000AA5300F36A74 AS DateTime), N'Function:IC STB Pairing[51]')
INSERT [dbo].[ICStatusChange] ([ID], [ICTableID], [InternalNumber], [STBID], [STBRealNumber], [ICStatus], [CustomerID], [DepartmentID], [Creator], [CreateTime], [Remark]) VALUES (33, 3, 796, 3, N'8778788000007966', 1, 2, 1, N'admin', CAST(0x0000AA5300F36BA0 AS DateTime), N'Function:IC STB Pairing[51]')
INSERT [dbo].[ICStatusChange] ([ID], [ICTableID], [InternalNumber], [STBID], [STBRealNumber], [ICStatus], [CustomerID], [DepartmentID], [Creator], [CreateTime], [Remark]) VALUES (34, 3, 796, 3, N'8778788000007966', 1, 2, 1, N'admin', CAST(0x0000AA5300F36CCC AS DateTime), N'Function:IC STB Pairing[51]')
INSERT [dbo].[ICStatusChange] ([ID], [ICTableID], [InternalNumber], [STBID], [STBRealNumber], [ICStatus], [CustomerID], [DepartmentID], [Creator], [CreateTime], [Remark]) VALUES (35, 3, 796, 3, N'8778788000007966', 1, 2, 1, N'admin', CAST(0x0000AA5300F36CCC AS DateTime), N'Function:IC STB Pairing[51]')
INSERT [dbo].[ICStatusChange] ([ID], [ICTableID], [InternalNumber], [STBID], [STBRealNumber], [ICStatus], [CustomerID], [DepartmentID], [Creator], [CreateTime], [Remark]) VALUES (36, 3, 796, 3, N'8778788000007966', 1, 2, 1, N'admin', CAST(0x0000AA5300F82500 AS DateTime), N'Function:Fingerprint[111]')
INSERT [dbo].[ICStatusChange] ([ID], [ICTableID], [InternalNumber], [STBID], [STBRealNumber], [ICStatus], [CustomerID], [DepartmentID], [Creator], [CreateTime], [Remark]) VALUES (37, 3, 796, 3, N'8778788000007966', 1, 2, 1, N'admin', CAST(0x0000AA5300F83A18 AS DateTime), N'Function:Fingerprint[111]')
SET IDENTITY_INSERT [dbo].[ICStatusChange] OFF
SET IDENTITY_INSERT [dbo].[ICSTBPairing] ON 

INSERT [dbo].[ICSTBPairing] ([ID], [ICTableID], [STBTableID]) VALUES (4, 3, 3)
SET IDENTITY_INSERT [dbo].[ICSTBPairing] OFF
SET IDENTITY_INSERT [dbo].[LogInfoManagement] ON 

INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (1, N'admin', N'Administrator', N'3', 2, NULL, N'ID[1]  Name[GENERAL]', CAST(0x0000AA5300E10834 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (2, N'admin', N'Administrator', N'4', 2, NULL, N'id:[1]|name:[ID]', CAST(0x0000AA5300E11068 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (3, N'admin', N'Administrator', N'6', 2, NULL, N'ID[1]  Model Name[ENSURITY] Provider Name[MCBS]', CAST(0x0000AA5300E120D0 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (4, N'admin', N'Administrator', N'7', 2, NULL, N'ID[2]  Model Name[CHAMPION 4000] Provider Name[MCBS]', CAST(0x0000AA5300E13BC4 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (5, N'admin', N'Administrator', N'14', 2, NULL, N'id:[2]|name:[GANDHINAGAR]|pid:[1]', CAST(0x0000AA5300E1477C AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (6, N'admin', N'Administrator', N'20', 2, NULL, N'ID:1 CAID:1   Name:HINDI KHABAR', CAST(0x0000AA5300E2A838 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (7, N'admin', N'Administrator', N'21', 2, NULL, N'Added Program  [1]HINDI KHABAR,   to Product [3]ALL PACKAGE', CAST(0x0000AA5300E2B8A0 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (8, N'admin', N'Administrator', N'29', 2, NULL, N'ID[1]  Price[0] Price Type[Init]', CAST(0x0000AA5300E2C7DC AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (9, N'admin', N'Administrator', N'25', 2, NULL, N'Operation Succeeded ID:[1]', CAST(0x0000AA5300E2E078 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (10, N'admin', N'Administrator', N'26', 2, NULL, N'Operation Succeeded ID:[2]', CAST(0x0000AA5300E2F590 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (11, N'admin', N'Administrator', N'27', 2, NULL, N'ID[1]  Price[250] Product ID[3] Product Name[ALL PACKAGE]', CAST(0x0000AA5300E30D00 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (12, N'admin', N'Administrator', N'17', 2, 1, N'ID[1]Internal Number[796]Provider[1] Customer ID[] IC Status[INACTIVE],Sub- Operator ID[1]', CAST(0x0000AA5300E39874 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (13, N'admin', N'Administrator', N'18', 2, NULL, N'ID[1]  STB Real Number[8778788000007966] Provider[2]Customer ID[] Status[In Store],Sub- Operator ID[1]', CAST(0x0000AA5300E3B110 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (14, N'admin', N'Administrator', N'33', 10, NULL, N'Customer ID[1]| Cost ID[1]', CAST(0x0000AA5300E57A18 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (15, N'admin', N'Administrator', N'34', 21, 1, N'OrderCard#UserCostID:[1]#ID[1]Internal Number[796]Provider[1] Customer ID[1] IC Status[ACTIVATED],Sub- Operator ID[1]', CAST(0x0000AA5300E586FC AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (16, N'admin', N'Administrator', N'35', 21, NULL, N'Order STB#UserCostID:[1]#ID[1]  STB Real Number[8778788000007966] Provider[2]Customer ID[1] Status[Normal],Sub- Operator ID[1]', CAST(0x0000AA5300E592B4 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (17, N'admin', N'Administrator', N'51', 22, 1, N'Customer ID[1]Internal Number[796]STB ID[1] STB Real Number[8778788000007966]', CAST(0x0000AA5300E5A31C AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (18, N'admin', N'Administrator', N'51', 22, 1, N'Customer ID[1]Internal Number[796]STB ID[1] STB Real Number[8778788000007966]', CAST(0x0000AA5300E5C194 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (19, N'admin', N'Administrator', N'51', 22, 1, N'Customer ID[1]Internal Number[796]STB ID[1] STB Real Number[8778788000007966]', CAST(0x0000AA5300E5C3EC AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (20, N'admin', N'Administrator', N'37', 21, 1, N'Ordinary OrderID[0]Internal Number[796]Product[1] Customer ID[1] IC Status[Effective],Start Date[20-05-2019 00:00:00],End Date[20-05-2020 00:00:00', CAST(0x0000AA5300E5D580 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (21, N'admin', N'Administrator', N'37', 21, NULL, N'Customer [1-SHUBHAM]IC Card [796;] Product[1-ALL PACKAGE;]', CAST(0x0000AA5300E5D580 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (22, N'admin', N'Administrator', N'40', 21, NULL, N'UserCostID[1]  Amount Receivable[4450.0000] Amount Paid[4450.0000]', CAST(0x0000AA5300E5DDB4 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (23, N'admin', N'Administrator', NULL, 12, 1, N'[1]ALL PACKAGE', CAST(0x0000AA5300E5DEE0 AS DateTime), N'127.0.0.1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (24, N'admin', N'Administrator', N'40', 12, 1, N'ID[1]Internal Number[796]Provider[1] Customer ID[1] IC Status[ACTIVATED],Sub- Operator ID[1]', CAST(0x0000AA5300E5DEE0 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (25, N'admin', N'Administrator', N'38', 21, 1, N'Customer [1-SHUBHAM]IC Card [796-8778788000007966]', CAST(0x0000AA5300E60A3C AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (26, N'admin', N'Administrator', N'40', 21, NULL, N'UserCostID[2]  Amount Receivable[-3000.0000] Amount Paid[-3000.0000]', CAST(0x0000AA5300E61144 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (27, N'admin', N'Administrator', NULL, 13, 1, N'[1]ALL PACKAGE', CAST(0x0000AA5300E61144 AS DateTime), N'127.0.0.1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (28, N'admin', N'Administrator', N'40', 12, 1, N'ID[1]Internal Number[796]Provider[1] Customer ID[1] IC Status[ACTIVATED],Sub- Operator ID[1]', CAST(0x0000AA5300E61270 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (29, N'admin', N'Administrator', N'37', 21, 1, N'Ordinary OrderID[0]Internal Number[796]Product[1] Customer ID[1] IC Status[Effective],Start Date[20-05-2019 00:00:00],End Date[20-05-2020 00:00:00', CAST(0x0000AA5300E61E28 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (30, N'admin', N'Administrator', N'37', 21, NULL, N'Customer [1-SHUBHAM]IC Card [796;] Product[1-ALL PACKAGE;]', CAST(0x0000AA5300E61E28 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (31, N'admin', N'Administrator', N'40', 21, NULL, N'UserCostID[3]  Amount Receivable[3000.0000] Amount Paid[3000.0000]', CAST(0x0000AA5300E6265C AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (32, N'admin', N'Administrator', NULL, 12, 1, N'[1]ALL PACKAGE', CAST(0x0000AA5300E6265C AS DateTime), N'127.0.0.1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (33, N'admin', N'Administrator', NULL, 13, 1, N'[1]ALL PACKAGE', CAST(0x0000AA5300E6265C AS DateTime), N'127.0.0.1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (34, N'admin', N'Administrator', N'40', 12, 1, N'ID[1]Internal Number[796]Provider[1] Customer ID[1] IC Status[ACTIVATED],Sub- Operator ID[1]', CAST(0x0000AA5300E6265C AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (35, N'admin', N'Administrator', N'38', 21, 1, N'Customer [1-SHUBHAM]IC Card [796-8778788000007966]', CAST(0x0000AA5300E6DF84 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (36, N'admin', N'Administrator', N'40', 21, NULL, N'UserCostID[4]  Amount Receivable[-3000.0000] Amount Paid[-3000.0000]', CAST(0x0000AA5300E6E560 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (37, N'admin', N'Administrator', NULL, 13, 1, N'[1]ALL PACKAGE', CAST(0x0000AA5300E6E560 AS DateTime), N'127.0.0.1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (38, N'admin', N'Administrator', NULL, 13, 1, N'[1]ALL PACKAGE', CAST(0x0000AA5300E6E560 AS DateTime), N'127.0.0.1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (39, N'admin', N'Administrator', N'40', 12, 1, N'ID[1]Internal Number[796]Provider[1] Customer ID[1] IC Status[ACTIVATED],Sub- Operator ID[1]', CAST(0x0000AA5300E6E68C AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (40, N'admin', N'Administrator', N'37', 21, 1, N'Ordinary OrderID[0]Internal Number[796]Product[1] Customer ID[1] IC Status[Effective],Start Date[20-05-2019 00:00:00],End Date[20-05-2020 00:00:00', CAST(0x0000AA5300E75964 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (41, N'admin', N'Administrator', N'37', 21, NULL, N'Customer [1-SHUBHAM]IC Card [796;] Product[1-ALL PACKAGE;]', CAST(0x0000AA5300E75964 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (42, N'admin', N'Administrator', N'40', 21, NULL, N'UserCostID[5]  Amount Receivable[3000.0000] Amount Paid[3000.0000]', CAST(0x0000AA5300E7606C AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (43, N'admin', N'Administrator', NULL, 12, 1, N'[1]ALL PACKAGE', CAST(0x0000AA5300E7606C AS DateTime), N'127.0.0.1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (44, N'admin', N'Administrator', NULL, 13, 1, N'[1]ALL PACKAGE', CAST(0x0000AA5300E7606C AS DateTime), N'127.0.0.1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (45, N'admin', N'Administrator', NULL, 13, 1, N'[1]ALL PACKAGE', CAST(0x0000AA5300E7606C AS DateTime), N'127.0.0.1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (46, N'admin', N'Administrator', N'40', 12, 1, N'ID[1]Internal Number[796]Provider[1] Customer ID[1] IC Status[ACTIVATED],Sub- Operator ID[1]', CAST(0x0000AA5300E7606C AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (47, N'admin', N'Administrator', NULL, 12, 1, N'[1]ALL PACKAGE', CAST(0x0000AA5300E78718 AS DateTime), N'127.0.0.1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (48, N'admin', N'Administrator', NULL, 13, 1, N'[1]ALL PACKAGE', CAST(0x0000AA5300E78718 AS DateTime), N'127.0.0.1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (49, N'admin', N'Administrator', NULL, 13, 1, N'[1]ALL PACKAGE', CAST(0x0000AA5300E78718 AS DateTime), N'127.0.0.1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (50, N'admin', N'Administrator', N'44', 12, 1, N'ID[1]Internal Number[796]Provider[1] Customer ID[1] IC Status[ACTIVATED],Sub- Operator ID[1]', CAST(0x0000AA5300E78718 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (51, N'admin', N'Administrator', NULL, 12, 1, N'[1]ALL PACKAGE', CAST(0x0000AA5300E78970 AS DateTime), N'127.0.0.1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (52, N'admin', N'Administrator', NULL, 13, 1, N'[1]ALL PACKAGE', CAST(0x0000AA5300E78970 AS DateTime), N'127.0.0.1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (53, N'admin', N'Administrator', NULL, 13, 1, N'[1]ALL PACKAGE', CAST(0x0000AA5300E78970 AS DateTime), N'127.0.0.1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (54, N'admin', N'Administrator', N'44', 12, 1, N'ID[1]Internal Number[796]Provider[1] Customer ID[1] IC Status[ACTIVATED],Sub- Operator ID[1]', CAST(0x0000AA5300E78970 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (55, N'admin', N'Administrator', NULL, 12, 1, N'[1]ALL PACKAGE', CAST(0x0000AA5300E78A9C AS DateTime), N'127.0.0.1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (56, N'admin', N'Administrator', NULL, 13, 1, N'[1]ALL PACKAGE', CAST(0x0000AA5300E78A9C AS DateTime), N'127.0.0.1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (57, N'admin', N'Administrator', NULL, 13, 1, N'[1]ALL PACKAGE', CAST(0x0000AA5300E78A9C AS DateTime), N'127.0.0.1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (58, N'admin', N'Administrator', N'44', 12, 1, N'ID[1]Internal Number[796]Provider[1] Customer ID[1] IC Status[ACTIVATED],Sub- Operator ID[1]', CAST(0x0000AA5300E78A9C AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (59, N'admin', N'Administrator', N'38', 21, 1, N'Customer [1-SHUBHAM]IC Card [796-8778788000007966]', CAST(0x0000AA5300E7BBD4 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (60, N'admin', N'Administrator', N'40', 21, NULL, N'UserCostID[6]  Amount Receivable[-3000.0000] Amount Paid[-3000.0000]', CAST(0x0000AA5300E7C1B0 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (61, N'admin', N'Administrator', NULL, 13, 1, N'[1]ALL PACKAGE', CAST(0x0000AA5300E7C1B0 AS DateTime), N'127.0.0.1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (62, N'admin', N'Administrator', NULL, 13, 1, N'[1]ALL PACKAGE', CAST(0x0000AA5300E7C1B0 AS DateTime), N'127.0.0.1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (63, N'admin', N'Administrator', NULL, 13, 1, N'[1]ALL PACKAGE', CAST(0x0000AA5300E7C1B0 AS DateTime), N'127.0.0.1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (64, N'admin', N'Administrator', N'40', 12, 1, N'ID[1]Internal Number[796]Provider[1] Customer ID[1] IC Status[ACTIVATED],Sub- Operator ID[1]', CAST(0x0000AA5300E7C1B0 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (65, N'admin', N'Administrator', N'37', 21, 1, N'Ordinary OrderID[0]Internal Number[796]Product[1] Customer ID[1] IC Status[Effective],Start Date[20-05-2019 00:00:00],End Date[20-05-2020 00:00:00', CAST(0x0000AA5300E81E44 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (66, N'admin', N'Administrator', N'37', 21, NULL, N'Customer [1-SHUBHAM]IC Card [796;] Product[1-ALL PACKAGE;]', CAST(0x0000AA5300E81E44 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (67, N'admin', N'Administrator', N'40', 21, NULL, N'UserCostID[7]  Amount Receivable[3000.0000] Amount Paid[3000.0000]', CAST(0x0000AA5300E8254C AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (68, N'admin', N'Administrator', NULL, 12, 1, N'[1]ALL PACKAGE', CAST(0x0000AA5300E8254C AS DateTime), N'127.0.0.1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (69, N'admin', N'Administrator', NULL, 13, 1, N'[1]ALL PACKAGE', CAST(0x0000AA5300E8254C AS DateTime), N'127.0.0.1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (70, N'admin', N'Administrator', NULL, 13, 1, N'[1]ALL PACKAGE', CAST(0x0000AA5300E8254C AS DateTime), N'127.0.0.1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (71, N'admin', N'Administrator', NULL, 13, 1, N'[1]ALL PACKAGE', CAST(0x0000AA5300E8254C AS DateTime), N'127.0.0.1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (72, N'admin', N'Administrator', N'40', 12, 1, N'ID[1]Internal Number[796]Provider[1] Customer ID[1] IC Status[ACTIVATED],Sub- Operator ID[1]', CAST(0x0000AA5300E8254C AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (73, N'admin', N'Administrator', N'21', 3, NULL, N'', CAST(0x0000AA5300E85B34 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (74, N'admin', N'Administrator', N'51', 23, 1, N'Customer ID[1]Internal Number[796]STB ID[1] STB Real Number[8778788000007966]', CAST(0x0000AA5300E87E5C AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (75, N'admin', N'Administrator', NULL, 13, 1, N'[1]ALL PACKAGE', CAST(0x0000AA5300E87E5C AS DateTime), N'127.0.0.1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (77, N'admin', N'Administrator', N'51', 22, 1, N'Customer ID[1]Internal Number[796]STB ID[1] STB Real Number[8778788000007966]', CAST(0x0000AA5300E8D898 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (78, N'admin', N'Administrator', N'51', 23, 1, N'Customer ID[1]Internal Number[796]STB ID[1] STB Real Number[8778788000007966]', CAST(0x0000AA5300E8DD48 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (79, N'admin', N'Administrator', NULL, 13, 1, N'[1]ALL PACKAGE', CAST(0x0000AA5300E8DD48 AS DateTime), N'127.0.0.1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (80, N'admin', N'Administrator', N'51', 22, 1, N'Customer ID[1]Internal Number[796]STB ID[1] STB Real Number[8778788000007966]', CAST(0x0000AA5300E95854 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (81, N'admin', N'Administrator', N'51', 22, 1, N'Customer ID[1]Internal Number[796]STB ID[1] STB Real Number[8778788000007966]', CAST(0x0000AA5300E95BD8 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (82, N'admin', N'Administrator', N'51', 22, 1, N'Customer ID[1]Internal Number[796]STB ID[1] STB Real Number[8778788000007966]', CAST(0x0000AA5300E95D04 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (83, N'admin', N'Administrator', N'51', 22, 1, N'Customer ID[1]Internal Number[796]STB ID[1] STB Real Number[8778788000007966]', CAST(0x0000AA5300E95D04 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (84, N'admin', N'Administrator', N'51', 22, 1, N'Customer ID[1]Internal Number[796]STB ID[1] STB Real Number[8778788000007966]', CAST(0x0000AA5300E95E30 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (85, N'admin', N'Administrator', N'51', 22, 1, N'Customer ID[1]Internal Number[796]STB ID[1] STB Real Number[8778788000007966]', CAST(0x0000AA5300E95F5C AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (86, N'admin', N'Administrator', N'37', 21, NULL, N'IC Card [796-8778788000007966] Product Ordered [1-ALL PACKAGE] Overlaps!', CAST(0x0000AA5300E97474 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (87, N'admin', N'Administrator', N'38', 21, 1, N'Customer [1-SHUBHAM]IC Card [796-8778788000007966]', CAST(0x0000AA5300E98284 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (88, N'admin', N'Administrator', N'40', 21, NULL, N'UserCostID[8]  Amount Receivable[-3000.0000] Amount Paid[-3000.0000]', CAST(0x0000AA5300E98860 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (89, N'admin', N'Administrator', NULL, 13, 1, N'[1]ALL PACKAGE', CAST(0x0000AA5300E98860 AS DateTime), N'127.0.0.1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (90, N'admin', N'Administrator', NULL, 13, 1, N'[1]ALL PACKAGE', CAST(0x0000AA5300E98860 AS DateTime), N'127.0.0.1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (91, N'admin', N'Administrator', NULL, 13, 1, N'[1]ALL PACKAGE', CAST(0x0000AA5300E98860 AS DateTime), N'127.0.0.1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (92, N'admin', N'Administrator', NULL, 13, 1, N'[1]ALL PACKAGE', CAST(0x0000AA5300E98860 AS DateTime), N'127.0.0.1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (93, N'admin', N'Administrator', N'40', 12, 1, N'ID[1]Internal Number[796]Provider[1] Customer ID[1] IC Status[ACTIVATED],Sub- Operator ID[1]', CAST(0x0000AA5300E98860 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (94, N'admin', N'Administrator', N'37', 21, 1, N'Ordinary OrderID[0]Internal Number[796]Product[1] Customer ID[1] IC Status[Effective],Start Date[20-05-2019 00:00:00],End Date[20-05-2020 00:00:00', CAST(0x0000AA5300E99670 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (95, N'admin', N'Administrator', N'37', 21, NULL, N'Customer [1-SHUBHAM]IC Card [796;] Product[1-ALL PACKAGE;]', CAST(0x0000AA5300E99670 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (96, N'admin', N'Administrator', N'40', 21, NULL, N'UserCostID[9]  Amount Receivable[3000.0000] Amount Paid[3000.0000]', CAST(0x0000AA5300E99D78 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (97, N'admin', N'Administrator', NULL, 12, 1, N'[1]ALL PACKAGE', CAST(0x0000AA5300E99D78 AS DateTime), N'127.0.0.1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (98, N'admin', N'Administrator', NULL, 13, 1, N'[1]ALL PACKAGE', CAST(0x0000AA5300E99D78 AS DateTime), N'127.0.0.1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (99, N'admin', N'Administrator', NULL, 13, 1, N'[1]ALL PACKAGE', CAST(0x0000AA5300E99D78 AS DateTime), N'127.0.0.1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (100, N'admin', N'Administrator', NULL, 13, 1, N'[1]ALL PACKAGE', CAST(0x0000AA5300E99D78 AS DateTime), N'127.0.0.1', 0)
GO
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (101, N'admin', N'Administrator', NULL, 13, 1, N'[1]ALL PACKAGE', CAST(0x0000AA5300E99D78 AS DateTime), N'127.0.0.1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (102, N'admin', N'Administrator', N'40', 12, 1, N'ID[1]Internal Number[796]Provider[1] Customer ID[1] IC Status[ACTIVATED],Sub- Operator ID[1]', CAST(0x0000AA5300E99D78 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (103, N'admin', N'Administrator', N'38', 21, 1, N'Customer [1-SHUBHAM]IC Card [796-8778788000007966]', CAST(0x0000AA5300EB6C5C AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (104, N'admin', N'Administrator', N'40', 21, NULL, N'UserCostID[10]  Amount Receivable[-3000.0000] Amount Paid[-3000.0000]', CAST(0x0000AA5300EB7364 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (105, N'admin', N'Administrator', NULL, 13, 1, N'[1]ALL PACKAGE', CAST(0x0000AA5300EB7364 AS DateTime), N'127.0.0.1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (106, N'admin', N'Administrator', NULL, 13, 1, N'[1]ALL PACKAGE', CAST(0x0000AA5300EB7364 AS DateTime), N'127.0.0.1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (107, N'admin', N'Administrator', NULL, 13, 1, N'[1]ALL PACKAGE', CAST(0x0000AA5300EB7364 AS DateTime), N'127.0.0.1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (108, N'admin', N'Administrator', NULL, 13, 1, N'[1]ALL PACKAGE', CAST(0x0000AA5300EB7364 AS DateTime), N'127.0.0.1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (109, N'admin', N'Administrator', NULL, 13, 1, N'[1]ALL PACKAGE', CAST(0x0000AA5300EB7364 AS DateTime), N'127.0.0.1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (110, N'admin', N'Administrator', N'40', 12, 1, N'ID[1]Internal Number[796]Provider[1] Customer ID[1] IC Status[ACTIVATED],Sub- Operator ID[1]', CAST(0x0000AA5300EB7490 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (111, N'admin', N'Administrator', N'51', 23, 1, N'Customer ID[1]Internal Number[796]STB ID[1] STB Real Number[8778788000007966]', CAST(0x0000AA5300EB8048 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (112, N'admin', N'Administrator', N'124', 3, 1, N'Canceled ID[1]Internal Number[796]Provider[1] Customer ID[] IC Status[CANCELED],Sub- Operator ID[1]', CAST(0x0000AA5300EB8E58 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (113, N'admin', N'Administrator', N'125', 21, NULL, N'Canceled ID[1]  STB Real Number[8778788000007966] Provider[2]Customer ID[] Status[Canceled],Sub- Operator ID[1]', CAST(0x0000AA5300EB968C AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (114, N'admin', N'Administrator', N'56', 21, 1, N'IC Card Recycle ID[1]Internal Number[796]Provider[1] Customer ID[] IC Status[INACTIVE],Sub- Operator ID[1]', CAST(0x0000AA5300EB9EC0 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (115, N'admin', N'Administrator', N'57', 3, NULL, N'ID[1]  STB Real Number[8778788000007966] Provider[2]Customer ID[] Status[In Store],Sub- Operator ID[1]', CAST(0x0000AA5300EBA5C8 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (116, N'admin', N'Administrator', N'57', 3, NULL, N'ID[0]  STB Real Number[8778788000007966] Provider[2]Customer ID[] Status[In Store],Sub- Operator ID[1]', CAST(0x0000AA5300EBA5C8 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (117, N'admin', N'Administrator', N'17', 4, 2, N'ID[2]Internal Number[796]Provider[1] Customer ID[] IC Status[INACTIVE],Sub- Operator ID[1]', CAST(0x0000AA5300EBF578 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (118, N'admin', N'Administrator', N'18', 4, NULL, N'ID[2,]', CAST(0x0000AA5300EBFC80 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (119, N'admin', N'Administrator', N'118', 21, NULL, N'Customer ID[1] ', CAST(0x0000AA5300EC0A90 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (120, N'admin', N'Administrator', NULL, 30, NULL, N'Login,Login to CAS', CAST(0x0000AA5300F1BA08 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (121, N'admin', N'Administrator', N'17', 2, 3, N'ID[3]Internal Number[796]Provider[1] Customer ID[] IC Status[INACTIVE],Sub- Operator ID[1]', CAST(0x0000AA5300F2088C AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (122, N'admin', N'Administrator', N'18', 2, NULL, N'ID[3]  STB Real Number[8778788000007966] Provider[2]Customer ID[] Status[In Store],Sub- Operator ID[1]', CAST(0x0000AA5300F20E68 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (123, N'admin', N'Administrator', N'33', 10, NULL, N'Customer ID[2]| Cost ID[11]', CAST(0x0000AA5300F23898 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (124, N'admin', N'Administrator', N'34', 21, 3, N'OrderCard#UserCostID:[11]#ID[3]Internal Number[796]Provider[1] Customer ID[2] IC Status[ACTIVATED],Sub- Operator ID[1]', CAST(0x0000AA5300F24900 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (125, N'admin', N'Administrator', N'35', 21, NULL, N'Order STB#UserCostID:[11]#ID[3]  STB Real Number[8778788000007966] Provider[2]Customer ID[2] Status[Normal],Sub- Operator ID[1]', CAST(0x0000AA5300F2D7F8 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (126, N'admin', N'Administrator', N'51', 22, 3, N'Customer ID[2]Internal Number[796]STB ID[3] STB Real Number[8778788000007966]', CAST(0x0000AA5300F2FD78 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (127, N'admin', N'Administrator', N'51', 22, 3, N'Customer ID[2]Internal Number[796]STB ID[3] STB Real Number[8778788000007966]', CAST(0x0000AA5300F36240 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (128, N'admin', N'Administrator', N'51', 22, 3, N'Customer ID[2]Internal Number[796]STB ID[3] STB Real Number[8778788000007966]', CAST(0x0000AA5300F3636C AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (129, N'admin', N'Administrator', N'51', 22, 3, N'Customer ID[2]Internal Number[796]STB ID[3] STB Real Number[8778788000007966]', CAST(0x0000AA5300F3681C AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (130, N'admin', N'Administrator', N'51', 22, 3, N'Customer ID[2]Internal Number[796]STB ID[3] STB Real Number[8778788000007966]', CAST(0x0000AA5300F36948 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (131, N'admin', N'Administrator', N'51', 22, 3, N'Customer ID[2]Internal Number[796]STB ID[3] STB Real Number[8778788000007966]', CAST(0x0000AA5300F36A74 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (132, N'admin', N'Administrator', N'51', 22, 3, N'Customer ID[2]Internal Number[796]STB ID[3] STB Real Number[8778788000007966]', CAST(0x0000AA5300F36BA0 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (133, N'admin', N'Administrator', N'51', 22, 3, N'Customer ID[2]Internal Number[796]STB ID[3] STB Real Number[8778788000007966]', CAST(0x0000AA5300F36CCC AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (134, N'admin', N'Administrator', N'51', 22, 3, N'Customer ID[2]Internal Number[796]STB ID[3] STB Real Number[8778788000007966]', CAST(0x0000AA5300F36DF8 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (135, N'admin', N'Administrator', N'37', 21, 3, N'Ordinary OrderID[0]Internal Number[796]Product[1] Customer ID[2] IC Status[Effective],Start Date[20-05-2019 00:00:00],End Date[20-05-2020 00:00:00', CAST(0x0000AA5300F3D644 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (136, N'admin', N'Administrator', N'37', 21, NULL, N'Customer [2-SHUBHAM]IC Card [796;] Product[1-ALL PACKAGE;]', CAST(0x0000AA5300F3D644 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (137, N'admin', N'Administrator', N'40', 21, NULL, N'UserCostID[11]  Amount Receivable[4450.0000] Amount Paid[4450.0000]', CAST(0x0000AA5300F3DFA4 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (138, N'admin', N'Administrator', NULL, 12, 3, N'[1]ALL PACKAGE', CAST(0x0000AA5300F3DFA4 AS DateTime), N'127.0.0.1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (139, N'admin', N'Administrator', N'40', 12, 3, N'ID[3]Internal Number[796]Provider[1] Customer ID[2] IC Status[ACTIVATED],Sub- Operator ID[1]', CAST(0x0000AA5300F3DFA4 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (140, N'admin', N'Administrator', N'38', 21, 3, N'Customer [2-SHUBHAM]IC Card [796-8778788000007966]', CAST(0x0000AA5300F3FCF0 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (141, N'admin', N'Administrator', N'40', 21, NULL, N'UserCostID[12]  Amount Receivable[-3000.0000] Amount Paid[-3000.0000]', CAST(0x0000AA5300F403F8 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (142, N'admin', N'Administrator', NULL, 13, 3, N'[1]ALL PACKAGE', CAST(0x0000AA5300F403F8 AS DateTime), N'127.0.0.1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (143, N'admin', N'Administrator', N'40', 12, 3, N'ID[3]Internal Number[796]Provider[1] Customer ID[2] IC Status[ACTIVATED],Sub- Operator ID[1]', CAST(0x0000AA5300F403F8 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (144, N'admin', N'Administrator', N'37', 21, 3, N'Ordinary OrderID[0]Internal Number[796]Product[1] Customer ID[2] IC Status[Effective],Start Date[20-05-2019 00:00:00],End Date[20-05-2020 00:00:00', CAST(0x0000AA5300F416B8 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (145, N'admin', N'Administrator', N'37', 21, NULL, N'Customer [2-SHUBHAM]IC Card [796;] Product[1-ALL PACKAGE;]', CAST(0x0000AA5300F416B8 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (146, N'admin', N'Administrator', N'40', 21, NULL, N'UserCostID[13]  Amount Receivable[3000.0000] Amount Paid[3000.0000]', CAST(0x0000AA5300F41EEC AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (147, N'admin', N'Administrator', NULL, 12, 3, N'[1]ALL PACKAGE', CAST(0x0000AA5300F41EEC AS DateTime), N'127.0.0.1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (148, N'admin', N'Administrator', NULL, 13, 3, N'[1]ALL PACKAGE', CAST(0x0000AA5300F41EEC AS DateTime), N'127.0.0.1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (149, N'admin', N'Administrator', N'40', 12, 3, N'ID[3]Internal Number[796]Provider[1] Customer ID[2] IC Status[ACTIVATED],Sub- Operator ID[1]', CAST(0x0000AA5300F41EEC AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (150, N'admin', N'Administrator', N'81', 2, NULL, N'Set All Programs', CAST(0x0000AA5300F4860C AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (151, N'admin', N'Administrator', N'93', 2, NULL, N'Un Force Fingerprint CAS:[CAS6]  ID[1] CASID[4611686018427387908] ECM_FINGERPRINT ECM_FINGERPRINT  And  By IC NO.  Greater Than or Equal to  10; ', CAST(0x0000AA5300F4E87C AS DateTime), N'::1', 1)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (152, N'admin', N'Administrator', N'93', 4, NULL, N'Operation Succeeded ID[1 ]', CAST(0x0000AA5300F51504 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (153, N'admin', N'Administrator', N'95', 2, NULL, N' CAS:[CAS6]  ID[2] CASID[4611686018427387909] EMM_FINGERPRINT EMM_FINGERPRINT  And  By IC NO.  Greater Than or Equal to  10; ', CAST(0x0000AA5300F57FA8 AS DateTime), N'::1', 2)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (154, N'admin', N'Administrator', N'95', 4, NULL, N'Operation Succeeded ID[2 ]', CAST(0x0000AA5300F58EE4 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (155, N'admin', N'Administrator', N'95', 2, NULL, N' CAS:[CAS6]  ID[3] CASID[4611686018427387910] EMM_FINGERPRINT EMM_FINGERPRINT  And  By IC NO.  Greater Than or Equal to  10; ', CAST(0x0000AA5300F5AD5C AS DateTime), N'::1', 3)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (156, N'admin', N'Administrator', N'95', 4, NULL, N'Operation Succeeded ID[3 ]', CAST(0x0000AA5300F5D084 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (157, N'admin', N'Administrator', N'92', 2, NULL, N'Force OSD CAS:[CAS6]  ID[4] CASID[4611686018427387911] FORCE_OSD FORCE_OSD  And  By IC NO.  Greater Than or Equal to  10; ', CAST(0x0000AA5300F60798 AS DateTime), N'::1', 4)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (158, N'admin', N'Administrator', N'92', 4, NULL, N'Operation Succeeded ID[4 ]', CAST(0x0000AA5300F6228C AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (159, N'admin', N'Administrator', N'86', 2, NULL, N' CAS:[CAS6]  ID[5] CASID[4611686018427387912] OSD OSD  And  By IC NO.  Greater Than or Equal to  10; ', CAST(0x0000AA5300F66300 AS DateTime), N'::1', 5)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (160, N'admin', N'Administrator', N'86', 4, NULL, N'Operation Succeeded ID[5 ]', CAST(0x0000AA5300F676EC AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (161, N'admin', N'Administrator', N'86', 2, NULL, N' CAS:[CAS6]  ID[6] CASID[4611686018427387913] OSD OSD  And  By IC NO.  Greater Than or Equal to  10; ', CAST(0x0000AA5300F6BC10 AS DateTime), N'::1', 6)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (162, N'admin', N'Administrator', N'86', 4, NULL, N'Operation Succeeded ID[6 ]', CAST(0x0000AA5300F6CB4C AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (163, N'admin', N'Administrator', N'82', 2, NULL, N'CAS:[CAS6]  ID[1] CASID[1]', CAST(0x0000AA5300F70260 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (164, N'admin', N'Administrator', N'82', 4, NULL, N'Operation Succeeded ID[1 ]', CAST(0x0000AA5300F73398 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (165, N'admin', N'Administrator', N'111', 21, NULL, N'Start ID[796] - End ID[796] Yes', CAST(0x0000AA5300F82500 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (166, N'admin', N'Administrator', N'111', 21, NULL, N'Start ID[796] - End ID[796] Yes', CAST(0x0000AA5300F83A18 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (167, N'admin', N'Administrator', NULL, 30, NULL, N'Login,Login to CAS', CAST(0x0000AA5300FAA85C AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (168, N'admin', N'Administrator', N'38', 21, 3, N'Customer [2-SHUBHAM]IC Card [796-8778788000007966]', CAST(0x0000AA5300FAB8C4 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (169, N'admin', N'Administrator', N'40', 21, NULL, N'UserCostID[14]  Amount Receivable[-3000.0000] Amount Paid[-3000.0000]', CAST(0x0000AA5300FAC224 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (170, N'admin', N'Administrator', NULL, 13, 3, N'[1]ALL PACKAGE', CAST(0x0000AA5300FAC224 AS DateTime), N'127.0.0.1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (171, N'admin', N'Administrator', NULL, 13, 3, N'[1]ALL PACKAGE', CAST(0x0000AA5300FAC224 AS DateTime), N'127.0.0.1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (172, N'admin', N'Administrator', N'40', 12, 3, N'ID[3]Internal Number[796]Provider[1] Customer ID[2] IC Status[ACTIVATED],Sub- Operator ID[1]', CAST(0x0000AA5300FAC350 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (173, N'admin', N'Administrator', N'37', 21, 3, N'Ordinary OrderID[0]Internal Number[796]Product[1] Customer ID[2] IC Status[Effective],Start Date[20-05-2019 00:00:00],End Date[20-05-2020 00:00:00', CAST(0x0000AA5300FB511C AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (174, N'admin', N'Administrator', N'37', 21, NULL, N'Customer [2-SHUBHAM]IC Card [796;] Product[1-ALL PACKAGE;]', CAST(0x0000AA5300FB511C AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (175, N'admin', N'Administrator', N'40', 21, NULL, N'UserCostID[15]  Amount Receivable[3000.0000] Amount Paid[3000.0000]', CAST(0x0000AA5300FB56F8 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (176, N'admin', N'Administrator', NULL, 12, 3, N'[1]ALL PACKAGE', CAST(0x0000AA5300FB56F8 AS DateTime), N'127.0.0.1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (177, N'admin', N'Administrator', NULL, 13, 3, N'[1]ALL PACKAGE', CAST(0x0000AA5300FB56F8 AS DateTime), N'127.0.0.1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (178, N'admin', N'Administrator', NULL, 13, 3, N'[1]ALL PACKAGE', CAST(0x0000AA5300FB56F8 AS DateTime), N'127.0.0.1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (179, N'admin', N'Administrator', N'40', 12, 3, N'ID[3]Internal Number[796]Provider[1] Customer ID[2] IC Status[ACTIVATED],Sub- Operator ID[1]', CAST(0x0000AA5300FB56F8 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (180, N'admin', N'Administrator', N'21', 3, NULL, N'Message from [CAS6]:[Disconnected to CAS]', CAST(0x0000AA5300FCA044 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (181, N'admin', N'Administrator', N'20', 2, NULL, N'Message from [CAS6]:[Disconnected to CAS]', CAST(0x0000AA5300FE8B48 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (182, N'admin', N'Administrator', NULL, 31, NULL, N'Exit', CAST(0x0000AA5300FE8FF8 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (183, N'admin', N'Administrator', NULL, 30, NULL, N'Login,Login to CAS', CAST(0x0000AA5300FE9124 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (184, N'admin', N'Administrator', N'20', 2, NULL, N'Program Info Exist', CAST(0x0000AA5300FEAE70 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (185, N'admin', N'Administrator', N'20', 2, NULL, N'ID:3 CAID:2   Name:DILLAGI', CAST(0x0000AA5300FEB44C AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (186, N'admin', N'Administrator', N'21', 3, NULL, N'Added Program [2]DILLAGI,   to Product [1]ALL PACKAGE;', CAST(0x0000AA5300FEC004 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (187, N'admin', N'Administrator', NULL, 30, NULL, N'Login,Login to CAS', CAST(0x0000AA53011F4F90 AS DateTime), N'::1', 0)
INSERT [dbo].[LogInfoManagement] ([LogID], [UserID], [UserName], [FunctionID], [EventType], [ICTableID], [Description], [OperateDateTime], [IPAddress], [ConditionalAddrID]) VALUES (188, N'admin', N'Administrator', NULL, 30, NULL, N'Login,Login to CAS', CAST(0x0000AA5400A10388 AS DateTime), N'::1', 0)
SET IDENTITY_INSERT [dbo].[LogInfoManagement] OFF
SET IDENTITY_INSERT [dbo].[OrderCard] ON 

INSERT [dbo].[OrderCard] ([ID], [UserCostID], [CustomerID], [ICTableID], [OrderFeePackageID], [PriceID], [Price], [PreferentialID], [Preferential], [OriginalFee], [RealFee], [OperateType], [Status], [BackOrderID], [Remark], [Creator], [CreateTime], [LastEditor], [LastEditTime]) VALUES (1, 1, 1, 1, NULL, 2, CAST(250.0000 AS Decimal(12, 4)), NULL, CAST(0.0000 AS Decimal(12, 4)), CAST(250.0000 AS Decimal(12, 4)), CAST(250.0000 AS Decimal(12, 4)), 1, 1, NULL, NULL, N'admin', CAST(0x0000AA5300E586FC AS DateTime), N'admin', CAST(0x0000AA5300E586FC AS DateTime))
INSERT [dbo].[OrderCard] ([ID], [UserCostID], [CustomerID], [ICTableID], [OrderFeePackageID], [PriceID], [Price], [PreferentialID], [Preferential], [OriginalFee], [RealFee], [OperateType], [Status], [BackOrderID], [Remark], [Creator], [CreateTime], [LastEditor], [LastEditTime]) VALUES (2, 11, 2, 3, NULL, 2, CAST(250.0000 AS Decimal(12, 4)), NULL, CAST(0.0000 AS Decimal(12, 4)), CAST(250.0000 AS Decimal(12, 4)), CAST(250.0000 AS Decimal(12, 4)), 1, 1, NULL, NULL, N'admin', CAST(0x0000AA5300F24900 AS DateTime), N'admin', CAST(0x0000AA5300F24900 AS DateTime))
SET IDENTITY_INSERT [dbo].[OrderCard] OFF
SET IDENTITY_INSERT [dbo].[OrderProduct] ON 

INSERT [dbo].[OrderProduct] ([ID], [UserCostID], [CustomerID], [ICTableID], [ProductID], [OrderFeePackageID], [PriceID], [Price], [PreferentialID], [Preferential], [OriginalFee], [RealFee], [StartDate], [EndDate], [OrderMonth], [AdjustDays], [OperateType], [RenewOriginateType], [Status], [BackOrderID], [Remark], [Creator], [CreateTime], [LastEditor], [LastEditTime], [AuthTime], [UnAuthTime], [AuthStatus], [ReferOrderID]) VALUES (1, 1, 1, 1, 3, NULL, 1, CAST(250.0000 AS Decimal(12, 4)), NULL, CAST(0.0000 AS Decimal(12, 4)), CAST(3000.0000 AS Decimal(12, 4)), CAST(3000.0000 AS Decimal(12, 4)), CAST(0x0000AA5300000000 AS DateTime), CAST(0x0000ABC100000000 AS DateTime), 12, 0, 1, 1, 2, NULL, N'', N'admin', CAST(0x0000AA5300E5D580 AS DateTime), N'admin', CAST(0x0000AA5300E60A3C AS DateTime), NULL, NULL, 2, 0)
INSERT [dbo].[OrderProduct] ([ID], [UserCostID], [CustomerID], [ICTableID], [ProductID], [OrderFeePackageID], [PriceID], [Price], [PreferentialID], [Preferential], [OriginalFee], [RealFee], [StartDate], [EndDate], [OrderMonth], [AdjustDays], [OperateType], [RenewOriginateType], [Status], [BackOrderID], [Remark], [Creator], [CreateTime], [LastEditor], [LastEditTime], [AuthTime], [UnAuthTime], [AuthStatus], [ReferOrderID]) VALUES (2, NULL, 1, 1, 3, NULL, 1, CAST(250.0000 AS Decimal(12, 4)), NULL, CAST(0.0000 AS Decimal(12, 4)), CAST(0.0000 AS Decimal(12, 4)), CAST(3000.0000 AS Decimal(12, 4)), CAST(0x0000AA5300000000 AS DateTime), CAST(0x0000ABC100000000 AS DateTime), 12, 0, 5, 1, 1, NULL, N'', N'admin', CAST(0x0000AA5300E5DEE0 AS DateTime), N'admin', CAST(0x0000AA5300E5DEE0 AS DateTime), CAST(0x0000AA5300E5DEE0 AS DateTime), CAST(0x0000AA5300E61144 AS DateTime), 1, 1)
INSERT [dbo].[OrderProduct] ([ID], [UserCostID], [CustomerID], [ICTableID], [ProductID], [OrderFeePackageID], [PriceID], [Price], [PreferentialID], [Preferential], [OriginalFee], [RealFee], [StartDate], [EndDate], [OrderMonth], [AdjustDays], [OperateType], [RenewOriginateType], [Status], [BackOrderID], [Remark], [Creator], [CreateTime], [LastEditor], [LastEditTime], [AuthTime], [UnAuthTime], [AuthStatus], [ReferOrderID]) VALUES (3, 2, 1, 1, 3, NULL, 1, CAST(250.0000 AS Decimal(12, 4)), NULL, CAST(0.0000 AS Decimal(12, 4)), CAST(0.0000 AS Decimal(12, 4)), CAST(-3000.0000 AS Decimal(12, 4)), CAST(0x0000AA5300000000 AS DateTime), CAST(0x0000ABC100000000 AS DateTime), 12, 0, 2, 1, 1, 1, N'Unsubscribed ICNumber [1] IC [796-8778788000007966]', N'admin', CAST(0x0000AA5300E60A3C AS DateTime), N'admin', CAST(0x0000AA5300E60A3C AS DateTime), NULL, NULL, 0, 0)
INSERT [dbo].[OrderProduct] ([ID], [UserCostID], [CustomerID], [ICTableID], [ProductID], [OrderFeePackageID], [PriceID], [Price], [PreferentialID], [Preferential], [OriginalFee], [RealFee], [StartDate], [EndDate], [OrderMonth], [AdjustDays], [OperateType], [RenewOriginateType], [Status], [BackOrderID], [Remark], [Creator], [CreateTime], [LastEditor], [LastEditTime], [AuthTime], [UnAuthTime], [AuthStatus], [ReferOrderID]) VALUES (4, NULL, 1, 1, 3, NULL, 1, CAST(250.0000 AS Decimal(12, 4)), NULL, CAST(0.0000 AS Decimal(12, 4)), CAST(0.0000 AS Decimal(12, 4)), CAST(3000.0000 AS Decimal(12, 4)), CAST(0x0000AA5300000000 AS DateTime), CAST(0x0000ABC100000000 AS DateTime), 12, 0, 6, 1, 2, NULL, N'', N'admin', CAST(0x0000AA5300E61144 AS DateTime), N'admin', CAST(0x0000AA5300E61144 AS DateTime), NULL, NULL, 2, 1)
INSERT [dbo].[OrderProduct] ([ID], [UserCostID], [CustomerID], [ICTableID], [ProductID], [OrderFeePackageID], [PriceID], [Price], [PreferentialID], [Preferential], [OriginalFee], [RealFee], [StartDate], [EndDate], [OrderMonth], [AdjustDays], [OperateType], [RenewOriginateType], [Status], [BackOrderID], [Remark], [Creator], [CreateTime], [LastEditor], [LastEditTime], [AuthTime], [UnAuthTime], [AuthStatus], [ReferOrderID]) VALUES (5, 3, 1, 1, 3, NULL, 1, CAST(250.0000 AS Decimal(12, 4)), NULL, CAST(0.0000 AS Decimal(12, 4)), CAST(3000.0000 AS Decimal(12, 4)), CAST(3000.0000 AS Decimal(12, 4)), CAST(0x0000AA5300000000 AS DateTime), CAST(0x0000ABC100000000 AS DateTime), 12, 0, 1, 1, 2, NULL, N'', N'admin', CAST(0x0000AA5300E61E28 AS DateTime), N'admin', CAST(0x0000AA5300E6DF84 AS DateTime), NULL, NULL, 2, 0)
INSERT [dbo].[OrderProduct] ([ID], [UserCostID], [CustomerID], [ICTableID], [ProductID], [OrderFeePackageID], [PriceID], [Price], [PreferentialID], [Preferential], [OriginalFee], [RealFee], [StartDate], [EndDate], [OrderMonth], [AdjustDays], [OperateType], [RenewOriginateType], [Status], [BackOrderID], [Remark], [Creator], [CreateTime], [LastEditor], [LastEditTime], [AuthTime], [UnAuthTime], [AuthStatus], [ReferOrderID]) VALUES (6, NULL, 1, 1, 3, NULL, 1, CAST(250.0000 AS Decimal(12, 4)), NULL, CAST(0.0000 AS Decimal(12, 4)), CAST(0.0000 AS Decimal(12, 4)), CAST(3000.0000 AS Decimal(12, 4)), CAST(0x0000AA5300000000 AS DateTime), CAST(0x0000ABC100000000 AS DateTime), 12, 0, 5, 1, 1, NULL, N'', N'admin', CAST(0x0000AA5300E6265C AS DateTime), N'admin', CAST(0x0000AA5300E6265C AS DateTime), CAST(0x0000AA5300E6265C AS DateTime), CAST(0x0000AA5300E6E560 AS DateTime), 1, 5)
INSERT [dbo].[OrderProduct] ([ID], [UserCostID], [CustomerID], [ICTableID], [ProductID], [OrderFeePackageID], [PriceID], [Price], [PreferentialID], [Preferential], [OriginalFee], [RealFee], [StartDate], [EndDate], [OrderMonth], [AdjustDays], [OperateType], [RenewOriginateType], [Status], [BackOrderID], [Remark], [Creator], [CreateTime], [LastEditor], [LastEditTime], [AuthTime], [UnAuthTime], [AuthStatus], [ReferOrderID]) VALUES (7, 4, 1, 1, 3, NULL, 1, CAST(250.0000 AS Decimal(12, 4)), NULL, CAST(0.0000 AS Decimal(12, 4)), CAST(0.0000 AS Decimal(12, 4)), CAST(-3000.0000 AS Decimal(12, 4)), CAST(0x0000AA5300000000 AS DateTime), CAST(0x0000ABC100000000 AS DateTime), 12, 0, 2, 1, 1, 5, N'Unsubscribed ICNumber [5] IC [796-8778788000007966]', N'admin', CAST(0x0000AA5300E6DF84 AS DateTime), N'admin', CAST(0x0000AA5300E6DF84 AS DateTime), NULL, NULL, 0, 0)
INSERT [dbo].[OrderProduct] ([ID], [UserCostID], [CustomerID], [ICTableID], [ProductID], [OrderFeePackageID], [PriceID], [Price], [PreferentialID], [Preferential], [OriginalFee], [RealFee], [StartDate], [EndDate], [OrderMonth], [AdjustDays], [OperateType], [RenewOriginateType], [Status], [BackOrderID], [Remark], [Creator], [CreateTime], [LastEditor], [LastEditTime], [AuthTime], [UnAuthTime], [AuthStatus], [ReferOrderID]) VALUES (8, NULL, 1, 1, 3, NULL, 1, CAST(250.0000 AS Decimal(12, 4)), NULL, CAST(0.0000 AS Decimal(12, 4)), CAST(0.0000 AS Decimal(12, 4)), CAST(3000.0000 AS Decimal(12, 4)), CAST(0x0000AA5300000000 AS DateTime), CAST(0x0000ABC100000000 AS DateTime), 12, 0, 6, 1, 2, NULL, N'', N'admin', CAST(0x0000AA5300E6E560 AS DateTime), N'admin', CAST(0x0000AA5300E6E560 AS DateTime), NULL, NULL, 2, 5)
INSERT [dbo].[OrderProduct] ([ID], [UserCostID], [CustomerID], [ICTableID], [ProductID], [OrderFeePackageID], [PriceID], [Price], [PreferentialID], [Preferential], [OriginalFee], [RealFee], [StartDate], [EndDate], [OrderMonth], [AdjustDays], [OperateType], [RenewOriginateType], [Status], [BackOrderID], [Remark], [Creator], [CreateTime], [LastEditor], [LastEditTime], [AuthTime], [UnAuthTime], [AuthStatus], [ReferOrderID]) VALUES (9, 5, 1, 1, 3, NULL, 1, CAST(250.0000 AS Decimal(12, 4)), NULL, CAST(0.0000 AS Decimal(12, 4)), CAST(3000.0000 AS Decimal(12, 4)), CAST(3000.0000 AS Decimal(12, 4)), CAST(0x0000AA5300000000 AS DateTime), CAST(0x0000ABC100000000 AS DateTime), 12, 0, 1, 1, 2, NULL, N'', N'admin', CAST(0x0000AA5300E75964 AS DateTime), N'admin', CAST(0x0000AA5300E7BBD4 AS DateTime), NULL, NULL, 2, 0)
INSERT [dbo].[OrderProduct] ([ID], [UserCostID], [CustomerID], [ICTableID], [ProductID], [OrderFeePackageID], [PriceID], [Price], [PreferentialID], [Preferential], [OriginalFee], [RealFee], [StartDate], [EndDate], [OrderMonth], [AdjustDays], [OperateType], [RenewOriginateType], [Status], [BackOrderID], [Remark], [Creator], [CreateTime], [LastEditor], [LastEditTime], [AuthTime], [UnAuthTime], [AuthStatus], [ReferOrderID]) VALUES (10, NULL, 1, 1, 3, NULL, 1, CAST(250.0000 AS Decimal(12, 4)), NULL, CAST(0.0000 AS Decimal(12, 4)), CAST(0.0000 AS Decimal(12, 4)), CAST(3000.0000 AS Decimal(12, 4)), CAST(0x0000AA5300000000 AS DateTime), CAST(0x0000ABC100000000 AS DateTime), 12, 0, 5, 1, 1, NULL, N'', N'admin', CAST(0x0000AA5300E7606C AS DateTime), N'admin', CAST(0x0000AA5300E7606C AS DateTime), CAST(0x0000AA5300E7606C AS DateTime), CAST(0x0000AA5300E7C1B0 AS DateTime), 1, 9)
INSERT [dbo].[OrderProduct] ([ID], [UserCostID], [CustomerID], [ICTableID], [ProductID], [OrderFeePackageID], [PriceID], [Price], [PreferentialID], [Preferential], [OriginalFee], [RealFee], [StartDate], [EndDate], [OrderMonth], [AdjustDays], [OperateType], [RenewOriginateType], [Status], [BackOrderID], [Remark], [Creator], [CreateTime], [LastEditor], [LastEditTime], [AuthTime], [UnAuthTime], [AuthStatus], [ReferOrderID]) VALUES (11, 6, 1, 1, 3, NULL, 1, CAST(250.0000 AS Decimal(12, 4)), NULL, CAST(0.0000 AS Decimal(12, 4)), CAST(0.0000 AS Decimal(12, 4)), CAST(-3000.0000 AS Decimal(12, 4)), CAST(0x0000AA5300000000 AS DateTime), CAST(0x0000ABC100000000 AS DateTime), 12, 0, 2, 1, 1, 9, N'Unsubscribed ICNumber [9] IC [796-8778788000007966]', N'admin', CAST(0x0000AA5300E7BBD4 AS DateTime), N'admin', CAST(0x0000AA5300E7BBD4 AS DateTime), NULL, NULL, 0, 0)
INSERT [dbo].[OrderProduct] ([ID], [UserCostID], [CustomerID], [ICTableID], [ProductID], [OrderFeePackageID], [PriceID], [Price], [PreferentialID], [Preferential], [OriginalFee], [RealFee], [StartDate], [EndDate], [OrderMonth], [AdjustDays], [OperateType], [RenewOriginateType], [Status], [BackOrderID], [Remark], [Creator], [CreateTime], [LastEditor], [LastEditTime], [AuthTime], [UnAuthTime], [AuthStatus], [ReferOrderID]) VALUES (12, NULL, 1, 1, 3, NULL, 1, CAST(250.0000 AS Decimal(12, 4)), NULL, CAST(0.0000 AS Decimal(12, 4)), CAST(0.0000 AS Decimal(12, 4)), CAST(3000.0000 AS Decimal(12, 4)), CAST(0x0000AA5300000000 AS DateTime), CAST(0x0000ABC100000000 AS DateTime), 12, 0, 6, 1, 2, NULL, N'', N'admin', CAST(0x0000AA5300E7C1B0 AS DateTime), N'admin', CAST(0x0000AA5300E7C1B0 AS DateTime), NULL, NULL, 2, 9)
INSERT [dbo].[OrderProduct] ([ID], [UserCostID], [CustomerID], [ICTableID], [ProductID], [OrderFeePackageID], [PriceID], [Price], [PreferentialID], [Preferential], [OriginalFee], [RealFee], [StartDate], [EndDate], [OrderMonth], [AdjustDays], [OperateType], [RenewOriginateType], [Status], [BackOrderID], [Remark], [Creator], [CreateTime], [LastEditor], [LastEditTime], [AuthTime], [UnAuthTime], [AuthStatus], [ReferOrderID]) VALUES (13, 7, 1, 1, 3, NULL, 1, CAST(250.0000 AS Decimal(12, 4)), NULL, CAST(0.0000 AS Decimal(12, 4)), CAST(3000.0000 AS Decimal(12, 4)), CAST(3000.0000 AS Decimal(12, 4)), CAST(0x0000AA5300000000 AS DateTime), CAST(0x0000ABC100000000 AS DateTime), 12, 0, 1, 1, 2, NULL, N'', N'admin', CAST(0x0000AA5300E81E44 AS DateTime), N'admin', CAST(0x0000AA5300E98284 AS DateTime), NULL, NULL, 2, 0)
INSERT [dbo].[OrderProduct] ([ID], [UserCostID], [CustomerID], [ICTableID], [ProductID], [OrderFeePackageID], [PriceID], [Price], [PreferentialID], [Preferential], [OriginalFee], [RealFee], [StartDate], [EndDate], [OrderMonth], [AdjustDays], [OperateType], [RenewOriginateType], [Status], [BackOrderID], [Remark], [Creator], [CreateTime], [LastEditor], [LastEditTime], [AuthTime], [UnAuthTime], [AuthStatus], [ReferOrderID]) VALUES (14, NULL, 1, 1, 3, NULL, 1, CAST(250.0000 AS Decimal(12, 4)), NULL, CAST(0.0000 AS Decimal(12, 4)), CAST(0.0000 AS Decimal(12, 4)), CAST(3000.0000 AS Decimal(12, 4)), CAST(0x0000AA5300000000 AS DateTime), CAST(0x0000ABC100000000 AS DateTime), 12, 0, 5, 1, 1, NULL, N'', N'admin', CAST(0x0000AA5300E8254C AS DateTime), N'admin', CAST(0x0000AA5300E8254C AS DateTime), CAST(0x0000AA5300E8254C AS DateTime), CAST(0x0000AA5300E87E5C AS DateTime), 1, 13)
INSERT [dbo].[OrderProduct] ([ID], [UserCostID], [CustomerID], [ICTableID], [ProductID], [OrderFeePackageID], [PriceID], [Price], [PreferentialID], [Preferential], [OriginalFee], [RealFee], [StartDate], [EndDate], [OrderMonth], [AdjustDays], [OperateType], [RenewOriginateType], [Status], [BackOrderID], [Remark], [Creator], [CreateTime], [LastEditor], [LastEditTime], [AuthTime], [UnAuthTime], [AuthStatus], [ReferOrderID]) VALUES (15, NULL, 1, 1, 3, NULL, 1, CAST(250.0000 AS Decimal(12, 4)), NULL, CAST(0.0000 AS Decimal(12, 4)), CAST(0.0000 AS Decimal(12, 4)), CAST(3000.0000 AS Decimal(12, 4)), CAST(0x0000AA5300000000 AS DateTime), CAST(0x0000ABC100000000 AS DateTime), 12, 0, 6, 1, 1, NULL, N'', N'admin', CAST(0x0000AA5300E87E5C AS DateTime), N'admin', CAST(0x0000AA5300E87E5C AS DateTime), NULL, NULL, 2, 13)
INSERT [dbo].[OrderProduct] ([ID], [UserCostID], [CustomerID], [ICTableID], [ProductID], [OrderFeePackageID], [PriceID], [Price], [PreferentialID], [Preferential], [OriginalFee], [RealFee], [StartDate], [EndDate], [OrderMonth], [AdjustDays], [OperateType], [RenewOriginateType], [Status], [BackOrderID], [Remark], [Creator], [CreateTime], [LastEditor], [LastEditTime], [AuthTime], [UnAuthTime], [AuthStatus], [ReferOrderID]) VALUES (16, 8, 1, 1, 3, NULL, 1, CAST(250.0000 AS Decimal(12, 4)), NULL, CAST(0.0000 AS Decimal(12, 4)), CAST(0.0000 AS Decimal(12, 4)), CAST(-3000.0000 AS Decimal(12, 4)), CAST(0x0000AA5300000000 AS DateTime), CAST(0x0000ABC100000000 AS DateTime), 12, 0, 2, 1, 1, 13, N'Unsubscribed ICNumber [13] IC [796-8778788000007966]', N'admin', CAST(0x0000AA5300E98284 AS DateTime), N'admin', CAST(0x0000AA5300E98284 AS DateTime), NULL, NULL, 0, 0)
INSERT [dbo].[OrderProduct] ([ID], [UserCostID], [CustomerID], [ICTableID], [ProductID], [OrderFeePackageID], [PriceID], [Price], [PreferentialID], [Preferential], [OriginalFee], [RealFee], [StartDate], [EndDate], [OrderMonth], [AdjustDays], [OperateType], [RenewOriginateType], [Status], [BackOrderID], [Remark], [Creator], [CreateTime], [LastEditor], [LastEditTime], [AuthTime], [UnAuthTime], [AuthStatus], [ReferOrderID]) VALUES (17, 9, 1, 1, 3, NULL, 1, CAST(250.0000 AS Decimal(12, 4)), NULL, CAST(0.0000 AS Decimal(12, 4)), CAST(3000.0000 AS Decimal(12, 4)), CAST(3000.0000 AS Decimal(12, 4)), CAST(0x0000AA5300000000 AS DateTime), CAST(0x0000ABC100000000 AS DateTime), 12, 0, 1, 1, 2, NULL, N'', N'admin', CAST(0x0000AA5300E99670 AS DateTime), N'admin', CAST(0x0000AA5300EB6C5C AS DateTime), NULL, NULL, 2, 0)
INSERT [dbo].[OrderProduct] ([ID], [UserCostID], [CustomerID], [ICTableID], [ProductID], [OrderFeePackageID], [PriceID], [Price], [PreferentialID], [Preferential], [OriginalFee], [RealFee], [StartDate], [EndDate], [OrderMonth], [AdjustDays], [OperateType], [RenewOriginateType], [Status], [BackOrderID], [Remark], [Creator], [CreateTime], [LastEditor], [LastEditTime], [AuthTime], [UnAuthTime], [AuthStatus], [ReferOrderID]) VALUES (18, NULL, 1, 1, 3, NULL, 1, CAST(250.0000 AS Decimal(12, 4)), NULL, CAST(0.0000 AS Decimal(12, 4)), CAST(0.0000 AS Decimal(12, 4)), CAST(3000.0000 AS Decimal(12, 4)), CAST(0x0000AA5300000000 AS DateTime), CAST(0x0000ABC100000000 AS DateTime), 12, 0, 5, 1, 1, NULL, N'', N'admin', CAST(0x0000AA5300E99D78 AS DateTime), N'admin', CAST(0x0000AA5300E99D78 AS DateTime), CAST(0x0000AA5300E99D78 AS DateTime), CAST(0x0000AA5300EB7364 AS DateTime), 1, 17)
INSERT [dbo].[OrderProduct] ([ID], [UserCostID], [CustomerID], [ICTableID], [ProductID], [OrderFeePackageID], [PriceID], [Price], [PreferentialID], [Preferential], [OriginalFee], [RealFee], [StartDate], [EndDate], [OrderMonth], [AdjustDays], [OperateType], [RenewOriginateType], [Status], [BackOrderID], [Remark], [Creator], [CreateTime], [LastEditor], [LastEditTime], [AuthTime], [UnAuthTime], [AuthStatus], [ReferOrderID]) VALUES (19, 10, 1, 1, 3, NULL, 1, CAST(250.0000 AS Decimal(12, 4)), NULL, CAST(0.0000 AS Decimal(12, 4)), CAST(0.0000 AS Decimal(12, 4)), CAST(-3000.0000 AS Decimal(12, 4)), CAST(0x0000AA5300000000 AS DateTime), CAST(0x0000ABC100000000 AS DateTime), 12, 0, 2, 1, 1, 17, N'Unsubscribed ICNumber [17] IC [796-8778788000007966]', N'admin', CAST(0x0000AA5300EB6C5C AS DateTime), N'admin', CAST(0x0000AA5300EB6C5C AS DateTime), NULL, NULL, 0, 0)
INSERT [dbo].[OrderProduct] ([ID], [UserCostID], [CustomerID], [ICTableID], [ProductID], [OrderFeePackageID], [PriceID], [Price], [PreferentialID], [Preferential], [OriginalFee], [RealFee], [StartDate], [EndDate], [OrderMonth], [AdjustDays], [OperateType], [RenewOriginateType], [Status], [BackOrderID], [Remark], [Creator], [CreateTime], [LastEditor], [LastEditTime], [AuthTime], [UnAuthTime], [AuthStatus], [ReferOrderID]) VALUES (20, NULL, 1, 1, 3, NULL, 1, CAST(250.0000 AS Decimal(12, 4)), NULL, CAST(0.0000 AS Decimal(12, 4)), CAST(0.0000 AS Decimal(12, 4)), CAST(3000.0000 AS Decimal(12, 4)), CAST(0x0000AA5300000000 AS DateTime), CAST(0x0000ABC100000000 AS DateTime), 12, 0, 6, 1, 2, NULL, N'', N'admin', CAST(0x0000AA5300EB7364 AS DateTime), N'admin', CAST(0x0000AA5300EB7364 AS DateTime), NULL, NULL, 2, 17)
INSERT [dbo].[OrderProduct] ([ID], [UserCostID], [CustomerID], [ICTableID], [ProductID], [OrderFeePackageID], [PriceID], [Price], [PreferentialID], [Preferential], [OriginalFee], [RealFee], [StartDate], [EndDate], [OrderMonth], [AdjustDays], [OperateType], [RenewOriginateType], [Status], [BackOrderID], [Remark], [Creator], [CreateTime], [LastEditor], [LastEditTime], [AuthTime], [UnAuthTime], [AuthStatus], [ReferOrderID]) VALUES (21, 11, 2, 3, 3, NULL, 1, CAST(250.0000 AS Decimal(12, 4)), NULL, CAST(0.0000 AS Decimal(12, 4)), CAST(3000.0000 AS Decimal(12, 4)), CAST(3000.0000 AS Decimal(12, 4)), CAST(0x0000AA5300000000 AS DateTime), CAST(0x0000ABC100000000 AS DateTime), 12, 0, 1, 1, 2, NULL, N'', N'admin', CAST(0x0000AA5300F3D518 AS DateTime), N'admin', CAST(0x0000AA5300F3FCF0 AS DateTime), NULL, NULL, 2, 0)
INSERT [dbo].[OrderProduct] ([ID], [UserCostID], [CustomerID], [ICTableID], [ProductID], [OrderFeePackageID], [PriceID], [Price], [PreferentialID], [Preferential], [OriginalFee], [RealFee], [StartDate], [EndDate], [OrderMonth], [AdjustDays], [OperateType], [RenewOriginateType], [Status], [BackOrderID], [Remark], [Creator], [CreateTime], [LastEditor], [LastEditTime], [AuthTime], [UnAuthTime], [AuthStatus], [ReferOrderID]) VALUES (22, NULL, 2, 3, 3, NULL, 1, CAST(250.0000 AS Decimal(12, 4)), NULL, CAST(0.0000 AS Decimal(12, 4)), CAST(0.0000 AS Decimal(12, 4)), CAST(3000.0000 AS Decimal(12, 4)), CAST(0x0000AA5300000000 AS DateTime), CAST(0x0000ABC100000000 AS DateTime), 12, 0, 5, 1, 1, NULL, N'', N'admin', CAST(0x0000AA5300F3DFA4 AS DateTime), N'admin', CAST(0x0000AA5300F3DFA4 AS DateTime), CAST(0x0000AA5300F3DFA4 AS DateTime), CAST(0x0000AA5300F403F8 AS DateTime), 1, 21)
INSERT [dbo].[OrderProduct] ([ID], [UserCostID], [CustomerID], [ICTableID], [ProductID], [OrderFeePackageID], [PriceID], [Price], [PreferentialID], [Preferential], [OriginalFee], [RealFee], [StartDate], [EndDate], [OrderMonth], [AdjustDays], [OperateType], [RenewOriginateType], [Status], [BackOrderID], [Remark], [Creator], [CreateTime], [LastEditor], [LastEditTime], [AuthTime], [UnAuthTime], [AuthStatus], [ReferOrderID]) VALUES (23, 12, 2, 3, 3, NULL, 1, CAST(250.0000 AS Decimal(12, 4)), NULL, CAST(0.0000 AS Decimal(12, 4)), CAST(0.0000 AS Decimal(12, 4)), CAST(-3000.0000 AS Decimal(12, 4)), CAST(0x0000AA5300000000 AS DateTime), CAST(0x0000ABC100000000 AS DateTime), 12, 0, 2, 1, 1, 21, N'Unsubscribed ICNumber [21] IC [796-8778788000007966]', N'admin', CAST(0x0000AA5300F3FCF0 AS DateTime), N'admin', CAST(0x0000AA5300F3FCF0 AS DateTime), NULL, NULL, 0, 0)
INSERT [dbo].[OrderProduct] ([ID], [UserCostID], [CustomerID], [ICTableID], [ProductID], [OrderFeePackageID], [PriceID], [Price], [PreferentialID], [Preferential], [OriginalFee], [RealFee], [StartDate], [EndDate], [OrderMonth], [AdjustDays], [OperateType], [RenewOriginateType], [Status], [BackOrderID], [Remark], [Creator], [CreateTime], [LastEditor], [LastEditTime], [AuthTime], [UnAuthTime], [AuthStatus], [ReferOrderID]) VALUES (24, NULL, 2, 3, 3, NULL, 1, CAST(250.0000 AS Decimal(12, 4)), NULL, CAST(0.0000 AS Decimal(12, 4)), CAST(0.0000 AS Decimal(12, 4)), CAST(3000.0000 AS Decimal(12, 4)), CAST(0x0000AA5300000000 AS DateTime), CAST(0x0000ABC100000000 AS DateTime), 12, 0, 6, 1, 2, NULL, N'', N'admin', CAST(0x0000AA5300F403F8 AS DateTime), N'admin', CAST(0x0000AA5300F403F8 AS DateTime), NULL, NULL, 2, 21)
INSERT [dbo].[OrderProduct] ([ID], [UserCostID], [CustomerID], [ICTableID], [ProductID], [OrderFeePackageID], [PriceID], [Price], [PreferentialID], [Preferential], [OriginalFee], [RealFee], [StartDate], [EndDate], [OrderMonth], [AdjustDays], [OperateType], [RenewOriginateType], [Status], [BackOrderID], [Remark], [Creator], [CreateTime], [LastEditor], [LastEditTime], [AuthTime], [UnAuthTime], [AuthStatus], [ReferOrderID]) VALUES (25, 13, 2, 3, 3, NULL, 1, CAST(250.0000 AS Decimal(12, 4)), NULL, CAST(0.0000 AS Decimal(12, 4)), CAST(3000.0000 AS Decimal(12, 4)), CAST(3000.0000 AS Decimal(12, 4)), CAST(0x0000AA5300000000 AS DateTime), CAST(0x0000ABC100000000 AS DateTime), 12, 0, 1, 1, 2, NULL, N'', N'admin', CAST(0x0000AA5300F416B8 AS DateTime), N'admin', CAST(0x0000AA5300FAB8C4 AS DateTime), NULL, NULL, 2, 0)
INSERT [dbo].[OrderProduct] ([ID], [UserCostID], [CustomerID], [ICTableID], [ProductID], [OrderFeePackageID], [PriceID], [Price], [PreferentialID], [Preferential], [OriginalFee], [RealFee], [StartDate], [EndDate], [OrderMonth], [AdjustDays], [OperateType], [RenewOriginateType], [Status], [BackOrderID], [Remark], [Creator], [CreateTime], [LastEditor], [LastEditTime], [AuthTime], [UnAuthTime], [AuthStatus], [ReferOrderID]) VALUES (26, NULL, 2, 3, 3, NULL, 1, CAST(250.0000 AS Decimal(12, 4)), NULL, CAST(0.0000 AS Decimal(12, 4)), CAST(0.0000 AS Decimal(12, 4)), CAST(3000.0000 AS Decimal(12, 4)), CAST(0x0000AA5300000000 AS DateTime), CAST(0x0000ABC100000000 AS DateTime), 12, 0, 5, 1, 1, NULL, N'', N'admin', CAST(0x0000AA5300F41EEC AS DateTime), N'admin', CAST(0x0000AA5300F41EEC AS DateTime), CAST(0x0000AA5300F41EEC AS DateTime), CAST(0x0000AA5300FAC224 AS DateTime), 1, 25)
INSERT [dbo].[OrderProduct] ([ID], [UserCostID], [CustomerID], [ICTableID], [ProductID], [OrderFeePackageID], [PriceID], [Price], [PreferentialID], [Preferential], [OriginalFee], [RealFee], [StartDate], [EndDate], [OrderMonth], [AdjustDays], [OperateType], [RenewOriginateType], [Status], [BackOrderID], [Remark], [Creator], [CreateTime], [LastEditor], [LastEditTime], [AuthTime], [UnAuthTime], [AuthStatus], [ReferOrderID]) VALUES (27, 14, 2, 3, 3, NULL, 1, CAST(250.0000 AS Decimal(12, 4)), NULL, CAST(0.0000 AS Decimal(12, 4)), CAST(0.0000 AS Decimal(12, 4)), CAST(-3000.0000 AS Decimal(12, 4)), CAST(0x0000AA5300000000 AS DateTime), CAST(0x0000ABC100000000 AS DateTime), 12, 0, 2, 1, 1, 25, N'Unsubscribed ICNumber [25] IC [796-8778788000007966]', N'admin', CAST(0x0000AA5300FAB8C4 AS DateTime), N'admin', CAST(0x0000AA5300FAB8C4 AS DateTime), NULL, NULL, 0, 0)
INSERT [dbo].[OrderProduct] ([ID], [UserCostID], [CustomerID], [ICTableID], [ProductID], [OrderFeePackageID], [PriceID], [Price], [PreferentialID], [Preferential], [OriginalFee], [RealFee], [StartDate], [EndDate], [OrderMonth], [AdjustDays], [OperateType], [RenewOriginateType], [Status], [BackOrderID], [Remark], [Creator], [CreateTime], [LastEditor], [LastEditTime], [AuthTime], [UnAuthTime], [AuthStatus], [ReferOrderID]) VALUES (28, NULL, 2, 3, 3, NULL, 1, CAST(250.0000 AS Decimal(12, 4)), NULL, CAST(0.0000 AS Decimal(12, 4)), CAST(0.0000 AS Decimal(12, 4)), CAST(3000.0000 AS Decimal(12, 4)), CAST(0x0000AA5300000000 AS DateTime), CAST(0x0000ABC100000000 AS DateTime), 12, 0, 6, 1, 2, NULL, N'', N'admin', CAST(0x0000AA5300FAC224 AS DateTime), N'admin', CAST(0x0000AA5300FAC224 AS DateTime), NULL, NULL, 2, 25)
INSERT [dbo].[OrderProduct] ([ID], [UserCostID], [CustomerID], [ICTableID], [ProductID], [OrderFeePackageID], [PriceID], [Price], [PreferentialID], [Preferential], [OriginalFee], [RealFee], [StartDate], [EndDate], [OrderMonth], [AdjustDays], [OperateType], [RenewOriginateType], [Status], [BackOrderID], [Remark], [Creator], [CreateTime], [LastEditor], [LastEditTime], [AuthTime], [UnAuthTime], [AuthStatus], [ReferOrderID]) VALUES (29, 15, 2, 3, 3, NULL, 1, CAST(250.0000 AS Decimal(12, 4)), NULL, CAST(0.0000 AS Decimal(12, 4)), CAST(3000.0000 AS Decimal(12, 4)), CAST(3000.0000 AS Decimal(12, 4)), CAST(0x0000AA5300000000 AS DateTime), CAST(0x0000ABC100000000 AS DateTime), 12, 0, 1, 1, 1, NULL, N'', N'admin', CAST(0x0000AA5300FB511C AS DateTime), N'admin', CAST(0x0000AA5300FB511C AS DateTime), NULL, NULL, 1, 0)
INSERT [dbo].[OrderProduct] ([ID], [UserCostID], [CustomerID], [ICTableID], [ProductID], [OrderFeePackageID], [PriceID], [Price], [PreferentialID], [Preferential], [OriginalFee], [RealFee], [StartDate], [EndDate], [OrderMonth], [AdjustDays], [OperateType], [RenewOriginateType], [Status], [BackOrderID], [Remark], [Creator], [CreateTime], [LastEditor], [LastEditTime], [AuthTime], [UnAuthTime], [AuthStatus], [ReferOrderID]) VALUES (30, NULL, 2, 3, 3, NULL, 1, CAST(250.0000 AS Decimal(12, 4)), NULL, CAST(0.0000 AS Decimal(12, 4)), CAST(0.0000 AS Decimal(12, 4)), CAST(3000.0000 AS Decimal(12, 4)), CAST(0x0000AA5300000000 AS DateTime), CAST(0x0000ABC100000000 AS DateTime), 12, 0, 5, 1, 1, NULL, N'', N'admin', CAST(0x0000AA5300FB56F8 AS DateTime), N'admin', CAST(0x0000AA5300FB56F8 AS DateTime), CAST(0x0000AA5300FB56F8 AS DateTime), CAST(0x0000ABC100000000 AS DateTime), 1, 29)
SET IDENTITY_INSERT [dbo].[OrderProduct] OFF
SET IDENTITY_INSERT [dbo].[OrderSTB] ON 

INSERT [dbo].[OrderSTB] ([ID], [UserCostID], [CustomerID], [STBID], [OrderFeePackageID], [PriceID], [Price], [PreferentialID], [Preferential], [OriginalFee], [RealFee], [OperateType], [Status], [BackOrderID], [Remark], [Creator], [CreateTime], [LastEditor], [LastEditTime]) VALUES (1, 1, 1, 1, NULL, 1, CAST(1200.0000 AS Decimal(12, 4)), NULL, CAST(0.0000 AS Decimal(12, 4)), CAST(1200.0000 AS Decimal(12, 4)), CAST(1200.0000 AS Decimal(12, 4)), 1, 1, NULL, NULL, N'admin', CAST(0x0000AA5300E592B4 AS DateTime), N'admin', CAST(0x0000AA5300E592B4 AS DateTime))
INSERT [dbo].[OrderSTB] ([ID], [UserCostID], [CustomerID], [STBID], [OrderFeePackageID], [PriceID], [Price], [PreferentialID], [Preferential], [OriginalFee], [RealFee], [OperateType], [Status], [BackOrderID], [Remark], [Creator], [CreateTime], [LastEditor], [LastEditTime]) VALUES (2, 11, 2, 3, NULL, 1, CAST(1200.0000 AS Decimal(12, 4)), NULL, CAST(0.0000 AS Decimal(12, 4)), CAST(1200.0000 AS Decimal(12, 4)), CAST(1200.0000 AS Decimal(12, 4)), 1, 1, NULL, NULL, N'admin', CAST(0x0000AA5300F2D7F8 AS DateTime), N'admin', CAST(0x0000AA5300F2D7F8 AS DateTime))
SET IDENTITY_INSERT [dbo].[OrderSTB] OFF
SET IDENTITY_INSERT [dbo].[OSDInfo] ON 

INSERT [dbo].[OSDInfo] ([ID], [CASVersion], [CAEveintID], [BeginCardID], [EndCardID], [RegionID], [ProductID], [OSDContent], [Priority], [SendCount], [BeginDateTime], [EndDateTime], [OSDFee], [ContentProvider], [Operator], [OperateDateTime], [Position], [FountSize], [FountType], [FountColor], [BackgroundColor], [DepartmentID], [Active], [Creator], [CreateTime], [LastEditor], [LastEditTime]) VALUES (1, 3, 1, 796, 796, NULL, 0, N'HYYYY', 1, 0, CAST(0x0000AA5300F6E2BC AS DateTime), CAST(0x0000AA5A00F6E2BC AS DateTime), CAST(0.0000 AS Decimal(12, 4)), N'dx', N'admin', CAST(0x0000AA5300F70260 AS DateTime), 0, 24, 0, -1, -8388480, 1, 0, N'admin', CAST(0x0000AA5300F70260 AS DateTime), N'admin', CAST(0x0000AA5300F73398 AS DateTime))
SET IDENTITY_INSERT [dbo].[OSDInfo] OFF
INSERT [dbo].[Permit] ([PermitID], [PermitName]) VALUES (1, N'View')
INSERT [dbo].[Permit] ([PermitID], [PermitName]) VALUES (2, N'Add')
INSERT [dbo].[Permit] ([PermitID], [PermitName]) VALUES (3, N'Edit')
INSERT [dbo].[Permit] ([PermitID], [PermitName]) VALUES (4, N'Delete')
INSERT [dbo].[Permit] ([PermitID], [PermitName]) VALUES (5, N'Publish')
INSERT [dbo].[Permit] ([PermitID], [PermitName]) VALUES (6, N'EditUserPermit')
INSERT [dbo].[Permit] ([PermitID], [PermitName]) VALUES (7, N'Import')
INSERT [dbo].[Permit] ([PermitID], [PermitName]) VALUES (8, N'ExportACTable')
INSERT [dbo].[Permit] ([PermitID], [PermitName]) VALUES (9, N'SaveCust')
INSERT [dbo].[Permit] ([PermitID], [PermitName]) VALUES (10, N'NormalOrder')
INSERT [dbo].[Permit] ([PermitID], [PermitName]) VALUES (11, N'PackageOrder')
INSERT [dbo].[Permit] ([PermitID], [PermitName]) VALUES (12, N'Authorize')
INSERT [dbo].[Permit] ([PermitID], [PermitName]) VALUES (13, N'UnAuthorize')
INSERT [dbo].[Permit] ([PermitID], [PermitName]) VALUES (14, N'Pause')
INSERT [dbo].[Permit] ([PermitID], [PermitName]) VALUES (15, N'Resume')
INSERT [dbo].[Permit] ([PermitID], [PermitName]) VALUES (16, N'ViewOwner')
INSERT [dbo].[Permit] ([PermitID], [PermitName]) VALUES (17, N'Distribute')
INSERT [dbo].[Permit] ([PermitID], [PermitName]) VALUES (18, N'ChangeEquipment')
INSERT [dbo].[Permit] ([PermitID], [PermitName]) VALUES (19, N'Instal')
INSERT [dbo].[Permit] ([PermitID], [PermitName]) VALUES (20, N'ViewParent')
INSERT [dbo].[Permit] ([PermitID], [PermitName]) VALUES (21, N'Submit')
INSERT [dbo].[Permit] ([PermitID], [PermitName]) VALUES (22, N'Pairing')
INSERT [dbo].[Permit] ([PermitID], [PermitName]) VALUES (23, N'CancelPairing')
INSERT [dbo].[Permit] ([PermitID], [PermitName]) VALUES (24, N'RePairing')
INSERT [dbo].[Permit] ([PermitID], [PermitName]) VALUES (25, N'ResetPwd')
INSERT [dbo].[Permit] ([PermitID], [PermitName]) VALUES (26, N'Abort')
INSERT [dbo].[Permit] ([PermitID], [PermitName]) VALUES (27, N'PreviewInvoice')
INSERT [dbo].[Permit] ([PermitID], [PermitName]) VALUES (28, N'UploadInvoiceTemplate')
INSERT [dbo].[Permit] ([PermitID], [PermitName]) VALUES (29, N'EditPassword')
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 1)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 2)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 3)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 4)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 5)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 6)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 7)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 8)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 9)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 10)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 11)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 12)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 13)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 14)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 15)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 16)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 17)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 18)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 19)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 20)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 21)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 22)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 23)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 24)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 25)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 26)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 27)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 28)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 29)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 30)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 31)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 32)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 33)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 34)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 35)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 36)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 37)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 38)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 39)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 40)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 41)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 42)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 43)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 44)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 45)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 46)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 47)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 48)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 49)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 50)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 51)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 52)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 53)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 54)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 55)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 56)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 57)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 58)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 59)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 60)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 61)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 62)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 63)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 64)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 65)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 66)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 67)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 68)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 69)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 70)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 71)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 72)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 73)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 74)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 75)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 76)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 77)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 78)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 79)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 80)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 81)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 82)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 83)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 84)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 85)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 86)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 87)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 88)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 89)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 90)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 91)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 92)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 93)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 94)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 95)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 96)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 97)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 98)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 99)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 100)
GO
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 101)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 102)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 103)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 104)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 105)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 106)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 107)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 108)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 109)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 110)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 111)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 112)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 113)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 114)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 115)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 116)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 117)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 118)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 119)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 120)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 121)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 122)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 123)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 124)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 125)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 126)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 127)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 128)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 129)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 130)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 131)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 132)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 133)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 134)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 135)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 136)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 137)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 138)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 139)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 140)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 141)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 142)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 143)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 144)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 145)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 146)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 147)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 148)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 149)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 150)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 151)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 152)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 153)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 154)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 155)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 156)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 157)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 158)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 159)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 160)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 161)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 162)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 163)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 164)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 165)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 166)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 167)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 168)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 169)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 170)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 171)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 172)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 173)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 174)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 175)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 176)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 177)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 178)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 179)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 180)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 181)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 182)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 183)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 184)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 185)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 186)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 187)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 188)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 189)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 190)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 191)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 192)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 193)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 194)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 195)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 196)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 197)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 198)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 199)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 200)
GO
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 201)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 202)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 203)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 204)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 205)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 206)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 207)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 208)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 209)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 210)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 211)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 212)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 213)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 214)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 215)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 216)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 217)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 218)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 219)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 220)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 221)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 222)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 223)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 224)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 225)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 226)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 227)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 228)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 229)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 230)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 231)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 232)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 233)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 234)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 235)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 236)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 237)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 238)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 239)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 240)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 241)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 242)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 243)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 244)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 245)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 246)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 247)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 248)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 249)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 250)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 251)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 252)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 253)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 254)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 255)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 256)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 257)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 258)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 259)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 260)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 261)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 262)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 263)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 264)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 265)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 266)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 267)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 268)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 269)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 270)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 271)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 272)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 273)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 274)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 275)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 276)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 277)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 278)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 279)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 280)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 281)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 282)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 283)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 284)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 285)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 286)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 287)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 288)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 289)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 290)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 291)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 292)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 293)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 294)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 295)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 296)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 297)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 298)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 299)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 300)
GO
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 301)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 302)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 303)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 304)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 305)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 306)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 307)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 308)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 309)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 310)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 311)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 312)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 313)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 314)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 315)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 316)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 317)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 318)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 319)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 320)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 321)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 322)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 323)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 324)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 325)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 326)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 327)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 328)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 329)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 330)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 331)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 332)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 333)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 334)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 335)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 336)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 337)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 338)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 339)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 340)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 341)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 342)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 343)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 344)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 345)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 346)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 347)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 348)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 349)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 350)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 351)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 352)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 353)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 354)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 355)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 356)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 357)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 358)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 359)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 360)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 361)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 362)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 363)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 364)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 365)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 366)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 367)
INSERT [dbo].[PermitGroupSetting] ([GroupID], [PermitRelationID]) VALUES (1, 368)
INSERT [dbo].[PPVProviderInfo] ([ID], [ProviderName], [Remark], [Active], [Creator], [CreateTime], [LastEditor], [LastEditTime]) VALUES (1, N'PPV1', N'', 1, N'system', CAST(0x0000AA5300DFDB27 AS DateTime), N'system', CAST(0x0000AA5300DFDB27 AS DateTime))
INSERT [dbo].[PPVProviderInfo] ([ID], [ProviderName], [Remark], [Active], [Creator], [CreateTime], [LastEditor], [LastEditTime]) VALUES (2, N'PPV2', N'', 1, N'system', CAST(0x0000AA5300DFDB27 AS DateTime), N'system', CAST(0x0000AA5300DFDB27 AS DateTime))
INSERT [dbo].[PPVProviderInfo] ([ID], [ProviderName], [Remark], [Active], [Creator], [CreateTime], [LastEditor], [LastEditTime]) VALUES (3, N'PPV3', N'', 1, N'system', CAST(0x0000AA5300DFDB27 AS DateTime), N'system', CAST(0x0000AA5300DFDB27 AS DateTime))
INSERT [dbo].[PPVProviderInfo] ([ID], [ProviderName], [Remark], [Active], [Creator], [CreateTime], [LastEditor], [LastEditTime]) VALUES (4, N'PPV4', N'', 1, N'system', CAST(0x0000AA5300DFDB27 AS DateTime), N'system', CAST(0x0000AA5300DFDB27 AS DateTime))
SET IDENTITY_INSERT [dbo].[PriceEquipment] ON 

INSERT [dbo].[PriceEquipment] ([PriceID], [ModelNumber], [Price], [DepartmentID], [StartDate], [EndDate], [Status], [Active], [Remark], [Creator], [CreateTime], [LastEditor], [LastEditTime]) VALUES (1, 2, CAST(1200.0000 AS Decimal(12, 4)), 1, CAST(0x0000AA5300000000 AS DateTime), CAST(0x0000AE8800000000 AS DateTime), 1, 1, NULL, N'admin', CAST(0x0000AA5300E2E078 AS DateTime), N'admin', CAST(0x0000AA5300E2E078 AS DateTime))
INSERT [dbo].[PriceEquipment] ([PriceID], [ModelNumber], [Price], [DepartmentID], [StartDate], [EndDate], [Status], [Active], [Remark], [Creator], [CreateTime], [LastEditor], [LastEditTime]) VALUES (2, 1, CAST(250.0000 AS Decimal(12, 4)), 1, CAST(0x0000AA5300000000 AS DateTime), CAST(0x0000AE8800000000 AS DateTime), 1, 1, NULL, N'admin', CAST(0x0000AA5300E2F590 AS DateTime), N'admin', CAST(0x0000AA5300E2F590 AS DateTime))
SET IDENTITY_INSERT [dbo].[PriceEquipment] OFF
SET IDENTITY_INSERT [dbo].[PriceOther] ON 

INSERT [dbo].[PriceOther] ([PriceID], [PriceType], [Price], [DepartmentID], [StartDate], [EndDate], [Status], [Active], [Remark], [Creator], [CreateTime], [LastEditor], [LastEditTime]) VALUES (1, 1, CAST(0.0000 AS Decimal(12, 4)), 1, CAST(0x0000AA5300000000 AS DateTime), CAST(0x0000AE8800000000 AS DateTime), 1, 1, NULL, N'admin', CAST(0x0000AA5300E2C7DC AS DateTime), N'admin', CAST(0x0000AA5300E2C7DC AS DateTime))
SET IDENTITY_INSERT [dbo].[PriceOther] OFF
SET IDENTITY_INSERT [dbo].[PriceProduct] ON 

INSERT [dbo].[PriceProduct] ([PriceID], [ProductID], [Price], [DepartmentID], [StartDate], [EndDate], [IsMaster], [Status], [Active], [Remark], [Creator], [CreateTime], [LastEditor], [LastEditTime]) VALUES (1, 3, CAST(250.0000 AS Decimal(12, 4)), 1, CAST(0x0000AA5300000000 AS DateTime), CAST(0x0000AE8800000000 AS DateTime), 1, 1, 1, NULL, N'admin', CAST(0x0000AA5300E30D00 AS DateTime), N'admin', CAST(0x0000AA5300E30D00 AS DateTime))
SET IDENTITY_INSERT [dbo].[PriceProduct] OFF
SET IDENTITY_INSERT [dbo].[ProductInfo] ON 

INSERT [dbo].[ProductInfo] ([ProductID], [CAProductID], [ProductName], [ProductType], [Limit_Flag], [Match_Flag], [Active], [Creator], [CreateTime], [LastEditor], [LastEditTime]) VALUES (1, 65534, N'No Scrambled', 0, 0, 0, 1, N'system', CAST(0x0000AA5300DFDB29 AS DateTime), N'system', CAST(0x0000AA5300DFDB29 AS DateTime))
INSERT [dbo].[ProductInfo] ([ProductID], [CAProductID], [ProductName], [ProductType], [Limit_Flag], [Match_Flag], [Active], [Creator], [CreateTime], [LastEditor], [LastEditTime]) VALUES (2, 65535, N'Data Broadcast', 0, 0, 0, 1, N'system', CAST(0x0000AA5300DFDB29 AS DateTime), N'system', CAST(0x0000AA5300DFDB29 AS DateTime))
INSERT [dbo].[ProductInfo] ([ProductID], [CAProductID], [ProductName], [ProductType], [Limit_Flag], [Match_Flag], [Active], [Creator], [CreateTime], [LastEditor], [LastEditTime]) VALUES (3, 1, N'ALL PACKAGE', 0, 0, 0, 1, N'admin', CAST(0x0000AA5300E2B774 AS DateTime), N'admin', CAST(0x0000AA5300FEC004 AS DateTime))
SET IDENTITY_INSERT [dbo].[ProductInfo] OFF
SET IDENTITY_INSERT [dbo].[ProductLog] ON 

INSERT [dbo].[ProductLog] ([ID], [ProductID], [CAProductID], [ProductType], [ProductName], [Limit_Flag], [Match_Flag], [Creator], [CreateTime], [Flag]) VALUES (1, 3, 1, 0, N'ALL PACKAGE', 0, 0, N'admin', CAST(0x0000AA5300E2B774 AS DateTime), 0)
INSERT [dbo].[ProductLog] ([ID], [ProductID], [CAProductID], [ProductType], [ProductName], [Limit_Flag], [Match_Flag], [Creator], [CreateTime], [Flag]) VALUES (2, 3, 1, 0, N'ALL PACKAGE', 0, 0, N'admin', CAST(0x0000AA5300E85B34 AS DateTime), 0)
INSERT [dbo].[ProductLog] ([ID], [ProductID], [CAProductID], [ProductType], [ProductName], [Limit_Flag], [Match_Flag], [Creator], [CreateTime], [Flag]) VALUES (4, 3, 1, 0, N'ALL PACKAGE', 0, 0, N'admin', CAST(0x0000AA5300FEC004 AS DateTime), 0)
SET IDENTITY_INSERT [dbo].[ProductLog] OFF
INSERT [dbo].[ProductProgramRelation] ([ProgramID], [ProductID]) VALUES (1, 3)
INSERT [dbo].[ProductProgramRelation] ([ProgramID], [ProductID]) VALUES (3, 3)
SET IDENTITY_INSERT [dbo].[ProductProgramRelationLog] ON 

INSERT [dbo].[ProductProgramRelationLog] ([ID], [ProductLogID], [ProgramID]) VALUES (1, 1, 1)
INSERT [dbo].[ProductProgramRelationLog] ([ID], [ProductLogID], [ProgramID]) VALUES (2, 2, 1)
INSERT [dbo].[ProductProgramRelationLog] ([ID], [ProductLogID], [ProgramID]) VALUES (3, 3, 1)
INSERT [dbo].[ProductProgramRelationLog] ([ID], [ProductLogID], [ProgramID]) VALUES (4, 4, 1)
INSERT [dbo].[ProductProgramRelationLog] ([ID], [ProductLogID], [ProgramID]) VALUES (5, 4, 3)
SET IDENTITY_INSERT [dbo].[ProductProgramRelationLog] OFF
INSERT [dbo].[ProgramFingerprintFor6] ([ProgramID], [DisplayPositionCode], [PositionX], [PositionY], [FontType], [FontSize], [FontColor], [BackgroudColor], [ColorTypeCode], [ShowTime], [StopTime], [OvertFlag], [ShowBackgroundFlag], [ShowSTBnumberFlag], [IsShow]) VALUES (1, 4, 0, 0, 0, 26, -65536, -16777216, 3, 50, 10, 1, 1, 1, 0)
SET IDENTITY_INSERT [dbo].[ProgramInfo] ON 

INSERT [dbo].[ProgramInfo] ([ProgramID], [CAProgramID], [BroadcasterID], [NetworkID], [TransportStreamID], [ServiceID], [ProgramName], [VisibleLevel], [ProgramTypeCode], [Active], [Creator], [CreateTime], [LastEditor], [LastEditTime]) VALUES (1, 1, NULL, 1, 1, 1, N'HINDI KHABAR', 1, 0, 1, N'admin', CAST(0x0000AA5300E2A70C AS DateTime), N'admin', CAST(0x0000AA5300E2A70C AS DateTime))
INSERT [dbo].[ProgramInfo] ([ProgramID], [CAProgramID], [BroadcasterID], [NetworkID], [TransportStreamID], [ServiceID], [ProgramName], [VisibleLevel], [ProgramTypeCode], [Active], [Creator], [CreateTime], [LastEditor], [LastEditTime]) VALUES (3, 2, NULL, 1, 1, 2, N'DILLAGI', 1, 0, 1, N'admin', CAST(0x0000AA5300FEB44C AS DateTime), N'admin', CAST(0x0000AA5300FEB44C AS DateTime))
SET IDENTITY_INSERT [dbo].[ProgramInfo] OFF
SET IDENTITY_INSERT [dbo].[ProgramLog] ON 

INSERT [dbo].[ProgramLog] ([ID], [ProgramID], [CAProgramID], [BroadcasterID], [ProgramName], [Fingerprint], [VisibleLevel], [ProgramType], [Creator], [CreateTime], [NetworkID], [TransportStreamID], [ServiceID]) VALUES (1, 1, 1, NULL, N'HINDI KHABAR', 0, 1, 0, N'admin', CAST(0x0000AA5300E2A70C AS DateTime), 1, 1, 1)
INSERT [dbo].[ProgramLog] ([ID], [ProgramID], [CAProgramID], [BroadcasterID], [ProgramName], [Fingerprint], [VisibleLevel], [ProgramType], [Creator], [CreateTime], [NetworkID], [TransportStreamID], [ServiceID]) VALUES (2, 1, 0, NULL, N'HINDI KHABAR', 0, 1, 0, N'admin', CAST(0x0000AA5300E2A70C AS DateTime), 1, 1, 1)
INSERT [dbo].[ProgramLog] ([ID], [ProgramID], [CAProgramID], [BroadcasterID], [ProgramName], [Fingerprint], [VisibleLevel], [ProgramType], [Creator], [CreateTime], [NetworkID], [TransportStreamID], [ServiceID]) VALUES (3, 3, 2, NULL, N'DILLAGI', 0, 1, 0, N'admin', CAST(0x0000AA5300FEB44C AS DateTime), 1, 1, 2)
SET IDENTITY_INSERT [dbo].[ProgramLog] OFF
SET IDENTITY_INSERT [dbo].[ProviderInfo] ON 

INSERT [dbo].[ProviderInfo] ([ModelNumber], [ProviderTypeCode], [ModelName], [ProviderName], [CAID], [Remark], [Active], [Creator], [CreateTime], [LastEditor], [LastEditTime]) VALUES (1, 1, N'ENSURITY', N'MCBS', 3, NULL, 1, N'admin', CAST(0x0000AA5300E120D0 AS DateTime), N'admin', CAST(0x0000AA5300E120D0 AS DateTime))
INSERT [dbo].[ProviderInfo] ([ModelNumber], [ProviderTypeCode], [ModelName], [ProviderName], [CAID], [Remark], [Active], [Creator], [CreateTime], [LastEditor], [LastEditTime]) VALUES (2, 2, N'CHAMPION 4000', N'MCBS', 3, NULL, 1, N'admin', CAST(0x0000AA5300E13BC4 AS DateTime), N'admin', CAST(0x0000AA5300E13BC4 AS DateTime))
SET IDENTITY_INSERT [dbo].[ProviderInfo] OFF
SET IDENTITY_INSERT [dbo].[STBInfo] ON 

INSERT [dbo].[STBInfo] ([STBID], [STBRealNumber], [ModelNumber], [CustomerID], [DepartmentID], [Status], [Active], [Creator], [CreateTime], [LastEditor], [LastEditTime]) VALUES (1, N'8778788000007966', 2, NULL, 1, 2, 0, N'admin', CAST(0x0000AA5300E3B110 AS DateTime), N'admin', CAST(0x0000AA5300EBA5C8 AS DateTime))
INSERT [dbo].[STBInfo] ([STBID], [STBRealNumber], [ModelNumber], [CustomerID], [DepartmentID], [Status], [Active], [Creator], [CreateTime], [LastEditor], [LastEditTime]) VALUES (3, N'8778788000007966', 2, 2, 1, 1, 1, N'admin', CAST(0x0000AA5300F20E68 AS DateTime), N'admin', CAST(0x0000AA5300F2D7F8 AS DateTime))
SET IDENTITY_INSERT [dbo].[STBInfo] OFF
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (1, NULL, N'MENU_System', N'系统设置', N'010000', NULL, NULL, 1, 10)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (2, 1, N'MENU_SystemParameter', N'系统参数配置', N'010100', N'SysConfig', N'Index', 1, 2)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (3, 1, N'MENU_CustomerType', N'客户类型管理', N'010200', N'CustomerType', N'List', 1, 3)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (4, 1, N'MENU_CertificateType', N'证件类型管理', N'010300', N'CertificateType', N'List', 1, 4)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (5, 1, N'MENU_Provider', N'供应商管理', N'010400', NULL, NULL, 1, 5)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (6, 5, N'MENU_Provider_IC', N'IC卡供应商', N'010401', N'ICProvider', N'List', 1, 6)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (7, 5, N'MENU_Provider_STB', N'STB供应商', N'010402', N'STBProvider', N'List', 1, 7)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (8, 5, N'MENU_Provider_PPV', N'PPV供应商', N'010403', N'PPVProvider', N'List', 1, 8)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (9, 1, N'MENU_Department', N'部门管理', N'010500', N'Dept', N'Index', 1, 9)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (10, 1, N'MENU_User', N'操作员管理', N'010600', N'UserInfo', N'List', 1, 11)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (11, 1, N'MENU_Group', N'权限组管理', N'010700', N'Group', N'List', 1, 10)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (12, 1, N'MENU_LOG', N'日志查询', N'010800', N'Loger', N'List', 1, 12)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (13, 1, N'MENU_CAInstance', N'CA管理', N'010900', N'CAInstance', N'List', 1, 2)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (14, 1, N'MENU_Region', N'区域管理', N'011000', N'Region', N'Index', 1, 8)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (15, NULL, N'MENU_EquipmentAndProduct', N'设备及产品管理', N'020000', NULL, NULL, 1, 20)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (16, 15, N'MENU_Equipment', N'设备管理', N'020100', NULL, NULL, 1, 1)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (17, 16, N'MENU_IC', N'IC管理', N'020101', N'ICCardInfo', N'Index', 1, 1)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (18, 16, N'MENU_STB', N'STB管理', N'020102', N'STBInfo', N'Index', 1, 1)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (19, 15, N'MENU_ProgramAndPrgPackage', N'??(?)??', N'020200', NULL, NULL, 1, 1)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (20, 19, N'MENU_Program', N'节目管理', N'020201', N'Program', N'List', 1, 1)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (21, 19, N'MENU_PrgPackage', N'节目包管理', N'020202', N'Product', N'List', 1, 1)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (22, NULL, N'MENU_TacticPrice', N'定价策略管理', N'030000', NULL, NULL, 1, 30)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (23, 22, N'MENU_Price', N'价格管理', N'030100', NULL, NULL, 1, 14)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (24, 22, N'MENU_TacticPreferential', N'优惠策略管理', N'030100', N'TacticPreferential', N'List', 1, 19)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (25, 23, N'MENU_Price_STB', N'STB价格管理', N'030101', N'PriceSTB', N'List', 1, 15)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (26, 23, N'MENU_Price_IC', N'IC卡价格管理', N'030102', N'PriceIC', N'List', 1, 16)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (27, 23, N'MENU_Price_Package', N'节目包价格管理', N'030103', N'PriceProduct', N'List', 1, 17)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (28, 23, N'MENU_Price_PPV', N'PPV价格管理', N'030104', N'PriceE_Notecase', N'List', 1, 18)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (29, 23, N'MENU_Price_Other', N'其他定价管理', N'030105', N'PriceOther', N'List', 1, 14)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (30, 22, N'MENU_Package', N'套餐管理', N'030200', N'FeePackage', N'Index', 1, 20)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (31, NULL, N'MENU_CompositeBusiness', N'综合业务管理', N'040000', NULL, NULL, 1, 40)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (32, 31, N'MENU_NormalBusiness', N'常用业务处理', N'040100', NULL, NULL, 1, 31)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (33, 32, N'MENU_CustomerInit', N'开户', N'040101', N'CustomerInit', N'Init', 1, 10)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (34, 32, N'MENU_OrderIC', N'购买IC卡', N'040102', N'OrderCard', N'Index', 1, 20)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (35, 32, N'MENU_OrderSTB', N'购买STB', N'040103', N'OrderSTB', N'Index', 1, 30)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (36, 32, N'MENU_Instal', N'初装', N'040104', N'Instal', N'Index', 1, 40)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (37, 32, N'MENU_OrderProduct', N'购买节目包', N'040105', N'OrderProduct', N'Index', 1, 50)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (38, 32, N'MENU_UnOrderProduct', N'退订节目包', N'040106', N'UnOrderProduct', N'Index', 1, 60)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (39, 32, N'MENU_OrderNotecase', N'电子钱包充值', N'040107', N'OrderPPV', N'Index', 1, 70)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (40, 32, N'MENU_Charge', N'收费', N'040108', N'Charge', N'Index', 1, 80)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (41, 32, N'MENU_ChargeException', N'收费异常处理', N'040109', N'ExceptionCharge', N'List', 1, 90)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (42, 32, N'MENU_OrderPrestore', N'预存签约', N'040109', N'OrderPrestore', N'Index', 0, 100)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (43, 32, N'MENU_UnOrderPrestore', N'取消预存签约', N'04010A', N'UnOrderPrestore', N'Index', 0, 110)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (44, 32, N'MENU_Authorization', N'授权管理', N'04010B', N'AuthorizeManagement', N'Index', 1, 120)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (45, 32, N'MENU_ChargeFeeModel', N'IC卡计费模式管理', N'04010C', N'CardService', N'ChargeFeeModel', 0, 130)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (46, 31, N'MENU_OtherBusiness', N'其他业务处理', N'040200', NULL, NULL, 1, 41)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (47, 46, N'MENU_Pause', N'停复机处理', N'040201', N'CardService', N'Index', 1, 10)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (48, 46, N'MENU_ChanageEuipment', N'更换设备', N'040202', N'ChangeEquipment', N'Index', 1, 20)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (49, 46, N'MENU_Transfer', N'过户', N'040203', N'ChangeOwner', N'Index', 1, 30)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (50, 46, N'MENU_ICPinUnlock', N'IC卡解锁', N'040204', N'ICPinUnlock', N'Index', 1, 40)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (51, 46, N'MENU_ICSTBPairing', N'IC卡机顶盒配对', N'040205', N'ICSTBPairing', N'Index', 1, 50)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (52, 46, N'MENU_ChildPrentSetting', N'子母卡设置', N'040206', N'ParentChildCardSetting', N'Index', 1, 60)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (53, 46, N'MENU_AuthorizeSynchronous', N'授权同步', N'040207', N'AuthorizeSynchronous', N'Index', 1, 70)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (54, 46, N'MENU_NetworkExcepionUnlock', N'网络异常解锁', N'040208', N'NetworkExceptionUnlock', N'Index', 0, 80)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (55, 46, N'MENU_SystemExcepionUnlock', N'系统异常解锁', N'040209', N'SystemExceptionUnlock', N'Index', 0, 90)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (56, 46, N'MENU_ICRecycle', N'IC卡回仓', N'04020A', N'ICRecycle', N'Index', 1, 100)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (57, 46, N'MENU_STBRecycle', N'机顶盒回仓', N'04020B', N'STBRecycle', N'Index', 1, 110)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (58, 80, N'MENU_NoAuthorizeWatch', N'未授权节目观看', N'04020C', N'NoAuthorizeWatch', N'Index', 1, 120)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (59, NULL, N'MENU_SystemFuncCAS4', N'CAS4功能', N'050000', NULL, NULL, 0, 50)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (60, 59, N'MENU_SystemFuncCAS4FingerSetting', N'CAS4指纹功能', N'050100', N'CAS4Finger', N'Index', 1, 50)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (61, 59, N'MENU_SystemFuncCAS4OSD', N'CAS4OSD', N'050200', N'CAS4OSD', N'Index', 1, 53)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (62, 59, N'MENU_SystemFuncCAS4Mail', N'CAS4Mail', N'050300', N'CAS4Mail', N'Index', 1, 54)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (63, 59, N'MENU_SystemFuncCAS4PPV', N'CAS4PPV', N'050400', N'CAS4PPV', N'Index', 1, 55)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (64, NULL, N'MENU_SystemFuncCAS5', N'CAS5功能', N'060000', NULL, NULL, 0, 60)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (65, NULL, N'MENU_SystemFuncCAS3', N'CAS3功能', N'060000', NULL, NULL, 0, 70)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (66, 65, N'MENU_SystemFuncCAS3OSD', N'CAS3OSD', N'060100', N'CAS3OSD', N'Index', 1, 1)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (67, 65, N'MENU_SystemFuncCAS3Mail', N'CAS3Mail', N'060100', N'CAS3Mail', N'Index', 1, 2)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (68, 64, N'MENU_SystemFuncCAS5FingerSetting', N'CAS5指纹功能', N'060100', N'CAS5Finger', N'Index', 1, 51)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (69, 64, N'MENU_SystemFuncCAS5OSD', N'CAS5OSD', N'060200', N'CAS5OSD', N'Index', 1, 54)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (70, 64, N'MENU_SystemFuncCAS5Mail', N'CAS5Mail', N'060300', N'CAS5Mail', N'Index', 1, 55)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (71, 64, N'MENU_SystemFuncCAS5PPV', N'CAS5PPV', N'060400', N'CAS5PPV', N'Index', 1, 55)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (72, 64, N'MENU_SystemFuncCAS5ConditionAuth', N'CAS5条件授权', N'060500', N'CAS5ConditionAuth', N'Index', 1, 56)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (73, 64, N'MENU_SystemFuncCAS5ConditionOSD', N'CAS5条件OSD', N'060600', N'CAS5ConditionOSD', N'Index', 1, 57)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (74, 64, N'MENU_SystemFuncCAS5ConditionLimit', N'CAS5条件限播', N'060700', N'CAS5ConditionLimit', N'Index', 1, 58)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (75, 64, N'MENU_SystemFuncCAS5ConditionMAIL', N'CAS5条件邮件', N'060800', N'CAS5ConditionMAIL', N'Index', 1, 59)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (76, 64, N'MENU_SystemFuncCAS5ConditionEmergency', N'紧急广播', N'060900', N'CAS5ConditionEmergency', N'Index', 1, 60)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (77, 64, N'MENU_SystemFuncCAS5ConditionNETUnlock', N'网络异常解锁', N'060A00', N'CAS5ConditionNETUnlock', N'Index', 1, 61)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (78, 64, N'MENU_SystemFuncCAS5ConditionSYSUnlock', N'系统异常解锁', N'060B00', N'CAS5ConditionSYSUnlock', N'Index', 1, 62)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (79, 64, N'MENU_SystemFuncCAS5ConditionSearch', N'条件节目搜索', N'060C00', N'CAS5ConditionSearch', N'Index', 1, 63)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (80, NULL, N'MENU_SystemFuncCAS6', N'CAS6功能', N'070000', NULL, NULL, 1, 80)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (81, 80, N'MENU_SystemFuncCAS6FingerSetting', N'CAS6????', N'070100', N'CAS6Finger', N'Index', 1, 52)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (82, 80, N'MENU_SystemFuncCAS6OSD', N'CAS6OSD', N'070200', N'CAS6OSD', N'Index', 1, 55)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (83, 80, N'MENU_SystemFuncCAS6Mail', N'CAS6Mail', N'070300', N'CAS6Mail', N'Index', 1, 56)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (84, 80, N'MENU_SystemFuncCAS6PPV', N'CAS6PPV', N'070400', N'CAS6PPV', N'Index', 1, 55)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (85, 80, N'MENU_SystemFuncCAS6ConditionAuth', N'CAS6条件授权', N'070500', N'CAS6ConditionAuth', N'Index', 1, 56)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (86, 80, N'MENU_SystemFuncCAS6ConditionOSD', N'CAS6条件OSD', N'070600', N'CAS6ConditionOSD', N'Index', 1, 57)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (87, 80, N'MENU_SystemFuncCAS6ConditionLimit', N'CAS6条件限播', N'070700', N'CAS6ConditionLimit', N'Index', 1, 58)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (88, 80, N'MENU_SystemFuncCAS6ConditionMAIL', N'CAS6条件邮件', N'070800', N'CAS6ConditionMAIL', N'Index', 1, 59)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (89, 80, N'MENU_SystemFuncCAS6ConditionEmergency', N'紧急广播', N'070900', N'CAS6ConditionEmergency', N'Index', 1, 60)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (90, 80, N'MENU_SystemFuncCAS6ConditionNETUnlock', N'网络异常解锁', N'070A00', N'CAS6ConditionNETUnlock', N'Index', 1, 61)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (91, 80, N'MENU_SystemFuncCAS6ConditionSYSUnlock', N'系统异常解锁', N'070B00', N'CAS6ConditionSYSUnlock', N'Index', 1, 62)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (92, 80, N'MENU_SystemFuncCAS6ConditionForceOSD', N'强制OSD', N'070B00', N'CAS6ConditionForceOSD', N'Index', 1, 64)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (93, 80, N'MENU_SystemFuncCAS6ConditionECMFinger', N'ECM指纹', N'070C00', N'CAS6ConditionECMFinger', N'Index', 1, 65)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (94, 80, N'MENU_SystemFuncCAS6ConditionSearch', N'条件节目搜索', N'070C00', N'CAS6ConditionSearch', N'Index', 1, 63)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (95, 80, N'MENU_SystemFuncCAS6ConditionEMMFinger', N'EMM指纹', N'070D00', N'CAS6ConditionEMMFinger', N'Index', 1, 66)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (96, NULL, N'MENU_CompositeSearch', N'综合业务查询', N'080000', NULL, NULL, 1, 90)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (97, 96, N'MENU_CustSearch', N'用户查询', N'080100', N'CompositeSearch', N'Customer', 1, 10)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (98, 96, N'MENU_FeeSearch', N'费用查询', N'080200', N'CompositeSearch', N'Fee', 1, 20)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (99, NULL, N'MENU_Report', N'报表', N'090000', NULL, NULL, 1, 100)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (100, 99, N'MENU_ReportBeDued', N'到期报表', N'090100', N'Report', N'BeDued', 1, 10)
GO
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (101, 99, N'MENU_ReportCardStatusInfo', N'IC卡状态报表', N'090200', N'Report', N'CardStatusInfo', 1, 20)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (102, 99, N'MENU_ReportChildParent', N'子母卡信息报表', N'090300', N'Report', N'ChildParent', 1, 30)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (103, 99, N'MENU_ReportCustomerCountByProduct', N'产品订购情况统计报表', N'090400', N'Report', N'CustomerCountByProduct', 1, 40)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (104, 99, N'MENU_ReportCustomerFeeDetails', N'客户费用明细报表', N'090500', N'Report', N'CustomerFeeDetails', 1, 50)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (105, 99, N'MENU_ReportEquipmentSale', N'设备销售情况报表', N'090600', N'Report', N'EquipmentSale', 1, 60)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (106, 99, N'MENU_ReportFeeByAddress', N'区域销售报表', N'090700', N'Report', N'FeeByAddress', 1, 70)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (107, 99, N'MENU_ReportStoppedIC', N'报停信息统计报表', N'090800', N'Report', N'StoppedIC', 1, 80)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (108, 99, N'MENU_ReportUserCharge', N'收费员收费统计报表', N'090900', N'Report', N'UserCharge', 1, 90)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (109, 32, N'MENU_EditCustomer', N'客户档案管理', N'04010E', N'Customer', N'Edit', 1, 11)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (111, 32, N'MENU_Fingerprint', N'指纹显示', N'04010D', N'CardService', N'FingerPrint', 1, 140)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (112, 46, N'MENU_PrintInvoice', N'发票重打', N'04020D', N'PrintInvoice', N'Index', 1, 130)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (113, 32, N'MENU_AreaLock', N'区域锁定', N'04010F', N'CardService', N'AreaLock', 1, 141)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (114, 96, N'MENU_RenewHistory', N'产品缴费查询', N'080300', N'RenewHistory', N'Index', 1, 30)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (115, 32, N'MENU_Renew', N'缴费', N'040110', N'Renew', N'Index', 0, 145)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (116, 96, N'MENU_StopHistory', N'报停记录查询', N'080400', N'StopHistory', N'Index', 1, 40)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (117, 32, N'MENU_DailySettleAccount', N'收费员日结', N'040111', N'Daily', N'Index', 1, 170)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (118, 32, N'MENU_CustomerCancel', N'销户', N'040112', N'CustomerCancel', N'Index', 1, 15)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (119, 32, N'MENU_BatchOrderProduct', N'按条件缴费', N'040113', N'BatchOrderProduct', N'Index', 1, 180)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (120, 32, N'MENU_BalanceRecharge', N'充值', N'040114', N'BalanceRecharge', N'Index', 1, 16)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (121, 96, N'MENU_ChangeEquipHis', N'更换设备记录查询', N'080500', N'ChangeEquipmentHis', N'Index', 1, 50)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (122, 96, N'MENU_BalanceRechargeHistory', N'充值记录查询', N'080600', N'BalanceRechargeHistory', N'Index', 1, 51)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (123, 32, N'MENU_BatchOrderCharge', N'批量订购收费', N'040115', N'BatchOrderCharge', N'Index', 1, 190)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (124, 46, N'MENU_ICCancel', N'IC卡注销', N'04020E', N'ICCancel', N'Index', 1, 131)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (125, 46, N'MENU_STBCancel', N'机顶盒注销', N'04020F', N'STBCancel', N'Index', 1, 132)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (126, 96, N'MENU_ChangedOwnerSearch', N'过户记录', N'080700', N'ChangeOwnerSearch', N'Index', 1, 52)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (127, 80, N'MENU_ICSTBPairingCA6', N'CAS6机卡配对', N'0700FF', N'ICSTBPairingCA6', N'Index', 1, 51)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (128, 96, N'MENU_ExportCASBuffer', N'导出CAS Buffer', N'080800', N'ExportCASBuffer', N'Index', 1, 53)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (129, 99, N'MENU_ReportProductAge', N'产品订购月数统计报表', N'090B00', N'Report', N'ReportProductAge', 1, 100)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (130, 99, N'MENU_ReportSubsOrderedandActived', N'产品订购和激活客户报表', N'090C00', N'Report', N'ReportSubsOrderedandActived', 1, 110)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (131, 99, N'MENU_ReportNoEquipmentCustomer', N'未订购任何设备客户报表', N'090D00', N'Report', N'ReportNoEquipmentCustomer', 1, 120)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (132, 99, N'MENU_ReportOnlineOfflineCustomer', N'每月开户和在网客户数量统计报表', N'090E00', N'Report', N'ReportOnlineOfflineCustomer', 1, 130)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (133, 99, N'MENU_ReportLostCustomer', N'流失客户报表', N'090A00', N'Report', N'ReportLostCustomer', 1, 140)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (134, 99, N'MENU_ReportProductFeeGroupByMonthAndPrice', N'分价格分产品收视费统报表', N'090A01', N'Report', N'ReportProductFeeGroupByMonthAndPrice', 1, 140)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (135, 99, N'MENU_ReportNewAccount', N'新增客户报表', N'090A02', N'Report', N'ReportNewAccount', 1, 140)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (136, 99, N'MENU_ReportRenew', N'续订客户报表', N'090A03', N'Report', N'ReportRenew', 1, 140)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (137, 96, N'MENU_RechargingSearch', N'短信或移动运营商充值查询', N'080900', N'CompositeSearch', N'RechargingSearch', 1, 54)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (138, 99, N'MENU_ReportActiveCardCountByProduct', N'产品订购IC卡激活情况统计报表', N'0809A04', N'Report', N'ReportActiveCardCountByProduct', 1, 141)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (139, 99, N'MENU_ReportActiveCardCountByStatusChange', N'IC卡激活状态统计报表', N'0809A05', N'Report', N'ReportActiveCardCountByStatusChange', 1, 142)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (140, 99, N'MENU_ReportProductHistory', N'产品日志报表', N'0809A06', N'Report', N'ReportProductHistory', 1, 142)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (141, 59, N'MENU_SystemFuncCAS4PreAuth', N'CAS4预授权', N'050500', N'CAS4PreAuth', N'Add', 1, 141)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (142, 59, N'MENU_SystemFuncCAS4CA4EmergencyBroadcast', N'MENU_SystemFuncCAS4CA4EmergencyBroadcast', N'0809A05', N'Report', N'CA4EmergencyBroadcast', 1, 142)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (143, 99, N'MENU_ReportCustomerAuthorization', N'MENU_ReportCustomerAuthorization', N'0809A05', N'Report', N'ReportCustomerAuthorization', 1, 142)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (144, 99, N'MENU_ReportCustomerOnNetwork', N'MENU_ReportCustomerOnNetwork', N'0809A05', N'Report', N'ReportCustomerOnNetwork', 1, 142)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (145, 99, N'MENU_ReportAlaCartePackageWiseAgeing', N'MENU_ReportAlaCartePackageWiseAgeing', N'0809A05', N'Report', N'ReportAlaCartePackageWiseAgeing', 1, 142)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (146, 99, N'MENU_ReportAlaCartePackageHistory', N'MENU_ReportAlaCartePackageHistory', N'0809A05', N'Report', N'ReportAlaCartePackageHistory', 1, 142)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (147, 99, N'MENU_ReportSTBVCActiveHistory', N'MENU_ReportSTBVCActiveHistory', N'0809A05', N'Report', N'ReportSTBVCHistory', 1, 142)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (148, 99, N'MENU_ReportPackageActiveSubscriptionDetail', N'MENU_ReportPackageActiveSubscriptionDetail', N'0809A05', N'Report', N'ReportPackageActiveSubscriptionDetail', 1, 142)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (149, 99, N'MENU_ReportMonthlySubscriber', N'MENU_ReportMonthlySubscriber', N'0809A05', N'Report', N'ReportMonthlySubscriber', 1, 142)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (150, 5, N'MENU_Broadcaster', N'MENU_Broadcaster', N'010404', N'BroadcasterInfo', N'List', 1, 150)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (151, 80, N'MENU_ICBlacklist', N'IC卡黑名单', N'070E00', N'ICBlacklist', N'List', 1, 151)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (152, 99, N'MENU_ReportICCardsAtNetwork', N'IC卡在网数量统计', N'0809A05', N'Report', N'ReportICCardsAtNetwork', 1, 21)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (153, 99, N'MENU_ReportDeactiveProductAge', N'ReportDeactiveProductAge', N'0809A05', N'Report', N'ReportDeactiveProductAge', 1, 153)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (154, 99, N'MENU_ReportDeActiveCardCountByStatusChange', N'IC卡激活状态统计报表', N'0809A05', N'Report', N'ReportDeActiveCardCountByStatusChange', 1, 143)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (155, 32, N'MENU_SignContract', N'缴费签约', N'040116', N'SignContract', N'AddInit', 1, 155)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (156, 32, N'MENU_EPCheck', N'对账查询', N'040117', N'EasyPayDayCheck', N'Index', 1, 156)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (157, 96, N'MENU_SignContractSearch', N'签约查询', N'080902', N'CompositeSearch', N'SignContractSearch', 1, 157)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (158, 32, N'MENU_FastNewAccount', N'快速开户', N'040118', N'FastNewAccount', N'Index', 1, 9)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (159, 99, N'MENU_ReportActiveAndDeactiveLog', N'ReportActiveAndDeactiveLog', N'0809A05', N'Report', N'ReportActiveAndDeactiveLog', 1, 159)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (160, 99, N'MENU_ReportAlaCarteChannels', N'ReportAlaCarteChannels', N'0809A06', N'Report', N'ReportAlaCarteChannels', 1, 160)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (161, 99, N'MENU_ReportMonthlySubscriptionBouquet', N'ReportMonthlySubscriptionBouquet', N'0809A07', N'Report', N'ReportMonthlySubscriptionBouquet', 1, 161)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (162, 99, N'MENU_ReportMonthlySubscriptionAlacate', N'ReportMonthlySubscriptionAlacate', N'0809A08', N'Report', N'ReportMonthlySubscriptionAlacate', 1, 162)
INSERT [dbo].[SysFunction] ([FunctionID], [ParentFunctionID], [FunctionCode], [FunctionName], [Layer], [Controller], [Action], [Visible], [SortSetting]) VALUES (163, 99, N'MENU_ReportLogInfo', N'ReportLogInfo', N'0809A09', N'Report', N'ReportLogInfo', 1, 163)
INSERT [dbo].[SystemSetting] ([Key], [Value], [Comment]) VALUES (N'AllowSlaveCardCount', N'99', N'允许子卡个数')
INSERT [dbo].[SystemSetting] ([Key], [Value], [Comment]) VALUES (N'BasicEdtFuncChildIDs', N'32,34,35,158,37,40,41', N'基本功能子级')
INSERT [dbo].[SystemSetting] ([Key], [Value], [Comment]) VALUES (N'BasicEdtFuncRootIDs', N'31', N'基本功能根级')
INSERT [dbo].[SystemSetting] ([Key], [Value], [Comment]) VALUES (N'CurrentDBVersion', N'11.1', N'')
INSERT [dbo].[SystemSetting] ([Key], [Value], [Comment]) VALUES (N'DailyAlarm', N'0', N'日结报警天数(0:不报警;其他值是报警天数)')
INSERT [dbo].[SystemSetting] ([Key], [Value], [Comment]) VALUES (N'DefaultPwd', N'123456', N'系统默认密码')
INSERT [dbo].[SystemSetting] ([Key], [Value], [Comment]) VALUES (N'InvoicePath', N'~/Reports/Invoice/', N'发票路径')
INSERT [dbo].[SystemSetting] ([Key], [Value], [Comment]) VALUES (N'InvoicePathBatch', N'~/Reports/InvoiceBatch/', N'批量订购发票路径')
INSERT [dbo].[SystemSetting] ([Key], [Value], [Comment]) VALUES (N'InvoicePrefix', N'', N'发票前缀')
INSERT [dbo].[SystemSetting] ([Key], [Value], [Comment]) VALUES (N'InvoiceTemplate', N'', N'发票模板')
INSERT [dbo].[SystemSetting] ([Key], [Value], [Comment]) VALUES (N'InvoiceTemplateBatch', N'', N'批量订购发票模板')
INSERT [dbo].[SystemSetting] ([Key], [Value], [Comment]) VALUES (N'InvoiceTitle', N'', N'发票抬头')
INSERT [dbo].[SystemSetting] ([Key], [Value], [Comment]) VALUES (N'InvoiceTitleBatch', N'', N'批量订购发票抬头')
INSERT [dbo].[SystemSetting] ([Key], [Value], [Comment]) VALUES (N'IsChargeResume', N'1', N'当前报开是否收费')
INSERT [dbo].[SystemSetting] ([Key], [Value], [Comment]) VALUES (N'OperatorCode', N'', N'运营商编码')
INSERT [dbo].[SystemSetting] ([Key], [Value], [Comment]) VALUES (N'OperatorName', N'', N'运营商名称')
INSERT [dbo].[SystemSetting] ([Key], [Value], [Comment]) VALUES (N'OperatorNumber', N'7787', N'')
INSERT [dbo].[SystemSetting] ([Key], [Value], [Comment]) VALUES (N'OrderProDefVal', N'12', N'默认订购月数')
INSERT [dbo].[SystemSetting] ([Key], [Value], [Comment]) VALUES (N'PairingRequired', N'1', N'机卡必须配对才能购买产品')
INSERT [dbo].[SystemSetting] ([Key], [Value], [Comment]) VALUES (N'PauseCalType', N'1', N'停复机计费方式')
INSERT [dbo].[SystemSetting] ([Key], [Value], [Comment]) VALUES (N'PrintInvoice', N'0', N'是否打印发票')
INSERT [dbo].[SystemSetting] ([Key], [Value], [Comment]) VALUES (N'RenewTypes', N'1', N'续费模式:1从当前开始续费;2:最后一次续费')
SET IDENTITY_INSERT [dbo].[UserCost] ON 

INSERT [dbo].[UserCost] ([ID], [CustomerID], [CustomerTypeID], [ChargeTime], [TacticPreferentialID], [RealFee], [OriginalFee], [IsPaid], [ChargeCash], [ChargeBalance], [Creator], [CreateTime], [LastEditor], [LastEditTime], [DailyID], [ChargeUser]) VALUES (1, 1, 1, CAST(0x0000AA5300E5DDB4 AS DateTime), NULL, CAST(4450.0000 AS Decimal(12, 4)), CAST(4450.0000 AS Decimal(12, 4)), 1, CAST(4450.0000 AS Decimal(12, 4)), CAST(0.0000 AS Decimal(12, 4)), N'admin', CAST(0x0000AA5300E57A18 AS DateTime), N'admin', CAST(0x0000AA5300E5DDB4 AS DateTime), NULL, N'admin')
INSERT [dbo].[UserCost] ([ID], [CustomerID], [CustomerTypeID], [ChargeTime], [TacticPreferentialID], [RealFee], [OriginalFee], [IsPaid], [ChargeCash], [ChargeBalance], [Creator], [CreateTime], [LastEditor], [LastEditTime], [DailyID], [ChargeUser]) VALUES (2, 1, 1, CAST(0x0000AA5300E61144 AS DateTime), NULL, CAST(-3000.0000 AS Decimal(12, 4)), CAST(0.0000 AS Decimal(12, 4)), 1, CAST(-3000.0000 AS Decimal(12, 4)), CAST(0.0000 AS Decimal(12, 4)), N'admin', CAST(0x0000AA5300E60A3C AS DateTime), N'admin', CAST(0x0000AA5300E61144 AS DateTime), NULL, N'admin')
INSERT [dbo].[UserCost] ([ID], [CustomerID], [CustomerTypeID], [ChargeTime], [TacticPreferentialID], [RealFee], [OriginalFee], [IsPaid], [ChargeCash], [ChargeBalance], [Creator], [CreateTime], [LastEditor], [LastEditTime], [DailyID], [ChargeUser]) VALUES (3, 1, 1, CAST(0x0000AA5300E6265C AS DateTime), NULL, CAST(3000.0000 AS Decimal(12, 4)), CAST(3000.0000 AS Decimal(12, 4)), 1, CAST(3000.0000 AS Decimal(12, 4)), CAST(0.0000 AS Decimal(12, 4)), N'admin', CAST(0x0000AA5300E61E28 AS DateTime), N'admin', CAST(0x0000AA5300E6265C AS DateTime), NULL, N'admin')
INSERT [dbo].[UserCost] ([ID], [CustomerID], [CustomerTypeID], [ChargeTime], [TacticPreferentialID], [RealFee], [OriginalFee], [IsPaid], [ChargeCash], [ChargeBalance], [Creator], [CreateTime], [LastEditor], [LastEditTime], [DailyID], [ChargeUser]) VALUES (4, 1, 1, CAST(0x0000AA5300E6E560 AS DateTime), NULL, CAST(-3000.0000 AS Decimal(12, 4)), CAST(0.0000 AS Decimal(12, 4)), 1, CAST(-3000.0000 AS Decimal(12, 4)), CAST(0.0000 AS Decimal(12, 4)), N'admin', CAST(0x0000AA5300E6DF84 AS DateTime), N'admin', CAST(0x0000AA5300E6E560 AS DateTime), NULL, N'admin')
INSERT [dbo].[UserCost] ([ID], [CustomerID], [CustomerTypeID], [ChargeTime], [TacticPreferentialID], [RealFee], [OriginalFee], [IsPaid], [ChargeCash], [ChargeBalance], [Creator], [CreateTime], [LastEditor], [LastEditTime], [DailyID], [ChargeUser]) VALUES (5, 1, 1, CAST(0x0000AA5300E7606C AS DateTime), NULL, CAST(3000.0000 AS Decimal(12, 4)), CAST(3000.0000 AS Decimal(12, 4)), 1, CAST(3000.0000 AS Decimal(12, 4)), CAST(0.0000 AS Decimal(12, 4)), N'admin', CAST(0x0000AA5300E75964 AS DateTime), N'admin', CAST(0x0000AA5300E7606C AS DateTime), NULL, N'admin')
INSERT [dbo].[UserCost] ([ID], [CustomerID], [CustomerTypeID], [ChargeTime], [TacticPreferentialID], [RealFee], [OriginalFee], [IsPaid], [ChargeCash], [ChargeBalance], [Creator], [CreateTime], [LastEditor], [LastEditTime], [DailyID], [ChargeUser]) VALUES (6, 1, 1, CAST(0x0000AA5300E7C1B0 AS DateTime), NULL, CAST(-3000.0000 AS Decimal(12, 4)), CAST(0.0000 AS Decimal(12, 4)), 1, CAST(-3000.0000 AS Decimal(12, 4)), CAST(0.0000 AS Decimal(12, 4)), N'admin', CAST(0x0000AA5300E7BBD4 AS DateTime), N'admin', CAST(0x0000AA5300E7C1B0 AS DateTime), NULL, N'admin')
INSERT [dbo].[UserCost] ([ID], [CustomerID], [CustomerTypeID], [ChargeTime], [TacticPreferentialID], [RealFee], [OriginalFee], [IsPaid], [ChargeCash], [ChargeBalance], [Creator], [CreateTime], [LastEditor], [LastEditTime], [DailyID], [ChargeUser]) VALUES (7, 1, 1, CAST(0x0000AA5300E8254C AS DateTime), NULL, CAST(3000.0000 AS Decimal(12, 4)), CAST(3000.0000 AS Decimal(12, 4)), 1, CAST(3000.0000 AS Decimal(12, 4)), CAST(0.0000 AS Decimal(12, 4)), N'admin', CAST(0x0000AA5300E81E44 AS DateTime), N'admin', CAST(0x0000AA5300E8254C AS DateTime), NULL, N'admin')
INSERT [dbo].[UserCost] ([ID], [CustomerID], [CustomerTypeID], [ChargeTime], [TacticPreferentialID], [RealFee], [OriginalFee], [IsPaid], [ChargeCash], [ChargeBalance], [Creator], [CreateTime], [LastEditor], [LastEditTime], [DailyID], [ChargeUser]) VALUES (8, 1, 1, CAST(0x0000AA5300E98860 AS DateTime), NULL, CAST(-3000.0000 AS Decimal(12, 4)), CAST(0.0000 AS Decimal(12, 4)), 1, CAST(-3000.0000 AS Decimal(12, 4)), CAST(0.0000 AS Decimal(12, 4)), N'admin', CAST(0x0000AA5300E98284 AS DateTime), N'admin', CAST(0x0000AA5300E98860 AS DateTime), NULL, N'admin')
INSERT [dbo].[UserCost] ([ID], [CustomerID], [CustomerTypeID], [ChargeTime], [TacticPreferentialID], [RealFee], [OriginalFee], [IsPaid], [ChargeCash], [ChargeBalance], [Creator], [CreateTime], [LastEditor], [LastEditTime], [DailyID], [ChargeUser]) VALUES (9, 1, 1, CAST(0x0000AA5300E99D78 AS DateTime), NULL, CAST(3000.0000 AS Decimal(12, 4)), CAST(3000.0000 AS Decimal(12, 4)), 1, CAST(3000.0000 AS Decimal(12, 4)), CAST(0.0000 AS Decimal(12, 4)), N'admin', CAST(0x0000AA5300E99670 AS DateTime), N'admin', CAST(0x0000AA5300E99D78 AS DateTime), NULL, N'admin')
INSERT [dbo].[UserCost] ([ID], [CustomerID], [CustomerTypeID], [ChargeTime], [TacticPreferentialID], [RealFee], [OriginalFee], [IsPaid], [ChargeCash], [ChargeBalance], [Creator], [CreateTime], [LastEditor], [LastEditTime], [DailyID], [ChargeUser]) VALUES (10, 1, 1, CAST(0x0000AA5300EB7364 AS DateTime), NULL, CAST(-3000.0000 AS Decimal(12, 4)), CAST(0.0000 AS Decimal(12, 4)), 1, CAST(-3000.0000 AS Decimal(12, 4)), CAST(0.0000 AS Decimal(12, 4)), N'admin', CAST(0x0000AA5300EB6C5C AS DateTime), N'admin', CAST(0x0000AA5300EB7364 AS DateTime), NULL, N'admin')
INSERT [dbo].[UserCost] ([ID], [CustomerID], [CustomerTypeID], [ChargeTime], [TacticPreferentialID], [RealFee], [OriginalFee], [IsPaid], [ChargeCash], [ChargeBalance], [Creator], [CreateTime], [LastEditor], [LastEditTime], [DailyID], [ChargeUser]) VALUES (11, 2, 1, CAST(0x0000AA5300F3DFA4 AS DateTime), NULL, CAST(4450.0000 AS Decimal(12, 4)), CAST(4450.0000 AS Decimal(12, 4)), 1, CAST(4450.0000 AS Decimal(12, 4)), CAST(0.0000 AS Decimal(12, 4)), N'admin', CAST(0x0000AA5300F23898 AS DateTime), N'admin', CAST(0x0000AA5300F3DFA4 AS DateTime), NULL, N'admin')
INSERT [dbo].[UserCost] ([ID], [CustomerID], [CustomerTypeID], [ChargeTime], [TacticPreferentialID], [RealFee], [OriginalFee], [IsPaid], [ChargeCash], [ChargeBalance], [Creator], [CreateTime], [LastEditor], [LastEditTime], [DailyID], [ChargeUser]) VALUES (12, 2, 1, CAST(0x0000AA5300F403F8 AS DateTime), NULL, CAST(-3000.0000 AS Decimal(12, 4)), CAST(0.0000 AS Decimal(12, 4)), 1, CAST(-3000.0000 AS Decimal(12, 4)), CAST(0.0000 AS Decimal(12, 4)), N'admin', CAST(0x0000AA5300F3FCF0 AS DateTime), N'admin', CAST(0x0000AA5300F403F8 AS DateTime), NULL, N'admin')
INSERT [dbo].[UserCost] ([ID], [CustomerID], [CustomerTypeID], [ChargeTime], [TacticPreferentialID], [RealFee], [OriginalFee], [IsPaid], [ChargeCash], [ChargeBalance], [Creator], [CreateTime], [LastEditor], [LastEditTime], [DailyID], [ChargeUser]) VALUES (13, 2, 1, CAST(0x0000AA5300F41EEC AS DateTime), NULL, CAST(3000.0000 AS Decimal(12, 4)), CAST(3000.0000 AS Decimal(12, 4)), 1, CAST(3000.0000 AS Decimal(12, 4)), CAST(0.0000 AS Decimal(12, 4)), N'admin', CAST(0x0000AA5300F416B8 AS DateTime), N'admin', CAST(0x0000AA5300F41EEC AS DateTime), NULL, N'admin')
INSERT [dbo].[UserCost] ([ID], [CustomerID], [CustomerTypeID], [ChargeTime], [TacticPreferentialID], [RealFee], [OriginalFee], [IsPaid], [ChargeCash], [ChargeBalance], [Creator], [CreateTime], [LastEditor], [LastEditTime], [DailyID], [ChargeUser]) VALUES (14, 2, 1, CAST(0x0000AA5300FAC224 AS DateTime), NULL, CAST(-3000.0000 AS Decimal(12, 4)), CAST(0.0000 AS Decimal(12, 4)), 1, CAST(-3000.0000 AS Decimal(12, 4)), CAST(0.0000 AS Decimal(12, 4)), N'admin', CAST(0x0000AA5300FAB8C4 AS DateTime), N'admin', CAST(0x0000AA5300FAC224 AS DateTime), NULL, N'admin')
INSERT [dbo].[UserCost] ([ID], [CustomerID], [CustomerTypeID], [ChargeTime], [TacticPreferentialID], [RealFee], [OriginalFee], [IsPaid], [ChargeCash], [ChargeBalance], [Creator], [CreateTime], [LastEditor], [LastEditTime], [DailyID], [ChargeUser]) VALUES (15, 2, 1, CAST(0x0000AA5300FB56F8 AS DateTime), NULL, CAST(3000.0000 AS Decimal(12, 4)), CAST(3000.0000 AS Decimal(12, 4)), 1, CAST(3000.0000 AS Decimal(12, 4)), CAST(0.0000 AS Decimal(12, 4)), N'admin', CAST(0x0000AA5300FB511C AS DateTime), N'admin', CAST(0x0000AA5300FB56F8 AS DateTime), NULL, N'admin')
SET IDENTITY_INSERT [dbo].[UserCost] OFF
INSERT [dbo].[UserInfo] ([UserID], [UserName], [Password], [Sex], [PhoneNumber], [MasterDepartmentID], [DepartmentID], [Active], [Creator], [CreateTime], [LastEditor], [LastEditTime]) VALUES (N'admin', N'Administrator', N'E10ADC3949BA59ABBE56E057F20F883E', 0, N'', 1, 1, 1, N'system', CAST(0x0000AA5300DFDB20 AS DateTime), N'system', CAST(0x0000AA5300DFDB20 AS DateTime))
INSERT [dbo].[UserInfo] ([UserID], [UserName], [Password], [Sex], [PhoneNumber], [MasterDepartmentID], [DepartmentID], [Active], [Creator], [CreateTime], [LastEditor], [LastEditTime]) VALUES (N'system', N'system', N'3F4896D8AABCBAE004AE742B8736BDFF', 0, N'', 1, 1, 1, N'system', CAST(0x0000AA5300DFDB20 AS DateTime), N'system', CAST(0x0000AA5300DFDB20 AS DateTime))
INSERT [dbo].[UserInfo_Group_Relation] ([UserID], [GroupID]) VALUES (N'admin', 1)
SET ANSI_PADDING ON

GO
/****** Object:  Index [_dta_index_CustomerInfo_5_18099105__K12_K1_K8_2_3_5_6_7_9_10]    Script Date: 02-06-2019 00:06:03 ******/
CREATE NONCLUSTERED INDEX [_dta_index_CustomerInfo_5_18099105__K12_K1_K8_2_3_5_6_7_9_10] ON [dbo].[CustomerInfo]
(
	[DepartmentID] ASC,
	[CustomerID] ASC,
	[RegionID] ASC
)
INCLUDE ( 	[CustomerNumber],
	[CustomerName],
	[CertificateID],
	[TelNumber],
	[MobilePhoneNumber],
	[Address],
	[CustTypeID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [_dta_index_CustomerInfo_7_18099105__K1_K12]    Script Date: 02-06-2019 00:06:03 ******/
CREATE NONCLUSTERED INDEX [_dta_index_CustomerInfo_7_18099105__K1_K12] ON [dbo].[CustomerInfo]
(
	[CustomerID] ASC,
	[DepartmentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [UK_CustNumber]    Script Date: 02-06-2019 00:06:03 ******/
CREATE UNIQUE NONCLUSTERED INDEX [UK_CustNumber] ON [dbo].[CustomerInfo]
(
	[CustomerNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [_dta_index_CustomerInit_7_949578421__K2_10]    Script Date: 02-06-2019 00:06:03 ******/
CREATE NONCLUSTERED INDEX [_dta_index_CustomerInit_7_949578421__K2_10] ON [dbo].[CustomerInit]
(
	[UserCostID] ASC
)
INCLUDE ( 	[RealFee]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [PK_Function_Permit_Relation]    Script Date: 02-06-2019 00:06:03 ******/
ALTER TABLE [dbo].[Function_Permit_Relation] ADD  CONSTRAINT [PK_Function_Permit_Relation] PRIMARY KEY NONCLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [_dta_index_ICCardInfo_5_2099048__K14_1_2_3]    Script Date: 02-06-2019 00:06:03 ******/
CREATE NONCLUSTERED INDEX [_dta_index_ICCardInfo_5_2099048__K14_1_2_3] ON [dbo].[ICCardInfo]
(
	[Status] ASC
)
INCLUDE ( 	[ID],
	[InternalNumber],
	[ExternalNumber]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [_dta_index_ICCardInfo_5_226099846__K1_2_3]    Script Date: 02-06-2019 00:06:03 ******/
CREATE NONCLUSTERED INDEX [_dta_index_ICCardInfo_5_226099846__K1_2_3] ON [dbo].[ICCardInfo]
(
	[ID] ASC
)
INCLUDE ( 	[InternalNumber],
	[ExternalNumber]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [_dta_index_ICCardInfo_5_226099846__K1_K4_K9_2_3_14]    Script Date: 02-06-2019 00:06:03 ******/
CREATE NONCLUSTERED INDEX [_dta_index_ICCardInfo_5_226099846__K1_K4_K9_2_3_14] ON [dbo].[ICCardInfo]
(
	[ID] ASC,
	[ParentICTableID] ASC,
	[ModelNumber] ASC
)
INCLUDE ( 	[InternalNumber],
	[ExternalNumber],
	[Status]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [_dta_index_ICCardInfo_7_226099846__K4_1]    Script Date: 02-06-2019 00:06:03 ******/
CREATE NONCLUSTERED INDEX [_dta_index_ICCardInfo_7_226099846__K4_1] ON [dbo].[ICCardInfo]
(
	[ParentICTableID] ASC
)
INCLUDE ( 	[ID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [_dta_index_OrderCard_7_1301579675__K2]    Script Date: 02-06-2019 00:06:03 ******/
CREATE NONCLUSTERED INDEX [_dta_index_OrderCard_7_1301579675__K2] ON [dbo].[OrderCard]
(
	[UserCostID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [_dta_index_OrderCard_7_1301579675__K2_11]    Script Date: 02-06-2019 00:06:03 ******/
CREATE NONCLUSTERED INDEX [_dta_index_OrderCard_7_1301579675__K2_11] ON [dbo].[OrderCard]
(
	[UserCostID] ASC
)
INCLUDE ( 	[RealFee]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [_dta_index_OrderCard_7_1301579675__K2_K4]    Script Date: 02-06-2019 00:06:03 ******/
CREATE NONCLUSTERED INDEX [_dta_index_OrderCard_7_1301579675__K2_K4] ON [dbo].[OrderCard]
(
	[UserCostID] ASC,
	[ICTableID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [_dta_index_OrderFeePackage_7_1365579903__K2_6]    Script Date: 02-06-2019 00:06:03 ******/
CREATE NONCLUSTERED INDEX [_dta_index_OrderFeePackage_7_1365579903__K2_6] ON [dbo].[OrderFeePackage]
(
	[UserCostID] ASC
)
INCLUDE ( 	[RealFee]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [_dta_index_OrderProduct_5_1301579675__K17_K19_K5_K4_K3_K1_K13_14]    Script Date: 02-06-2019 00:06:03 ******/
CREATE NONCLUSTERED INDEX [_dta_index_OrderProduct_5_1301579675__K17_K19_K5_K4_K3_K1_K13_14] ON [dbo].[OrderProduct]
(
	[OperateType] ASC,
	[Status] ASC,
	[ProductID] ASC,
	[ICTableID] ASC,
	[CustomerID] ASC,
	[ID] ASC,
	[StartDate] ASC
)
INCLUDE ( 	[EndDate]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [_dta_index_OrderProduct_5_1301579675__K20_K5_K4_K17_K19_K3_K1_K13_14]    Script Date: 02-06-2019 00:06:03 ******/
CREATE NONCLUSTERED INDEX [_dta_index_OrderProduct_5_1301579675__K20_K5_K4_K17_K19_K3_K1_K13_14] ON [dbo].[OrderProduct]
(
	[BackOrderID] ASC,
	[ProductID] ASC,
	[ICTableID] ASC,
	[OperateType] ASC,
	[Status] ASC,
	[CustomerID] ASC,
	[ID] ASC,
	[StartDate] ASC
)
INCLUDE ( 	[EndDate]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [_dta_index_OrderProduct_5_1301579675__K3_K19_K17_K2_14]    Script Date: 02-06-2019 00:06:03 ******/
CREATE NONCLUSTERED INDEX [_dta_index_OrderProduct_5_1301579675__K3_K19_K17_K2_14] ON [dbo].[OrderProduct]
(
	[CustomerID] ASC,
	[Status] ASC,
	[OperateType] ASC,
	[UserCostID] ASC
)
INCLUDE ( 	[EndDate]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [_dta_index_OrderProduct_5_1525580473__K2_K18_K17_K3_4_5_13_14_16]    Script Date: 02-06-2019 00:06:03 ******/
CREATE NONCLUSTERED INDEX [_dta_index_OrderProduct_5_1525580473__K2_K18_K17_K3_4_5_13_14_16] ON [dbo].[OrderProduct]
(
	[UserCostID] ASC,
	[Status] ASC,
	[OperateType] ASC,
	[CustomerID] ASC
)
INCLUDE ( 	[ICTableID],
	[ProductID],
	[StartDate],
	[EndDate],
	[AdjustDays]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [_dta_index_OrderProduct_7_1525580473__K17_K2_12]    Script Date: 02-06-2019 00:06:03 ******/
CREATE NONCLUSTERED INDEX [_dta_index_OrderProduct_7_1525580473__K17_K2_12] ON [dbo].[OrderProduct]
(
	[OperateType] ASC,
	[UserCostID] ASC
)
INCLUDE ( 	[RealFee]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [_dta_index_OrderProduct_7_1525580473__K2_K17_12]    Script Date: 02-06-2019 00:06:03 ******/
CREATE NONCLUSTERED INDEX [_dta_index_OrderProduct_7_1525580473__K2_K17_12] ON [dbo].[OrderProduct]
(
	[UserCostID] ASC,
	[OperateType] ASC
)
INCLUDE ( 	[RealFee]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [_dta_index_OrderProduct_7_1525580473__K6_K7_K2_12]    Script Date: 02-06-2019 00:06:03 ******/
CREATE NONCLUSTERED INDEX [_dta_index_OrderProduct_7_1525580473__K6_K7_K2_12] ON [dbo].[OrderProduct]
(
	[OrderFeePackageID] ASC,
	[PriceID] ASC,
	[UserCostID] ASC
)
INCLUDE ( 	[RealFee]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [_dta_index_OrderSTB_7_1605580758__K2]    Script Date: 02-06-2019 00:06:03 ******/
CREATE NONCLUSTERED INDEX [_dta_index_OrderSTB_7_1605580758__K2] ON [dbo].[OrderSTB]
(
	[UserCostID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [_dta_index_OrderSTB_7_1605580758__K2_11]    Script Date: 02-06-2019 00:06:03 ******/
CREATE NONCLUSTERED INDEX [_dta_index_OrderSTB_7_1605580758__K2_11] ON [dbo].[OrderSTB]
(
	[UserCostID] ASC
)
INCLUDE ( 	[RealFee]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [_dta_index_Stop_7_1669580986__K2_13]    Script Date: 02-06-2019 00:06:03 ******/
CREATE NONCLUSTERED INDEX [_dta_index_Stop_7_1669580986__K2_13] ON [dbo].[Stop]
(
	[UserCostID] ASC
)
INCLUDE ( 	[RealFee]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [PK_SysFunction]    Script Date: 02-06-2019 00:06:03 ******/
ALTER TABLE [dbo].[SysFunction] ADD  CONSTRAINT [PK_SysFunction] PRIMARY KEY NONCLUSTERED 
(
	[FunctionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [_dta_index_UserCost_5_1573580644__K8_K1]    Script Date: 02-06-2019 00:06:03 ******/
CREATE NONCLUSTERED INDEX [_dta_index_UserCost_5_1573580644__K8_K1] ON [dbo].[UserCost]
(
	[IsPaid] ASC,
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [_dta_index_UserCost_7_1797581442__K4_K1_K8_K2_6_9]    Script Date: 02-06-2019 00:06:03 ******/
CREATE NONCLUSTERED INDEX [_dta_index_UserCost_7_1797581442__K4_K1_K8_K2_6_9] ON [dbo].[UserCost]
(
	[ChargeTime] ASC,
	[ID] ASC,
	[IsPaid] ASC,
	[CustomerID] ASC,
	[ChargeUser] ASC
)
INCLUDE ( 	[RealFee],
	[ChargeCash]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AddressRegion] ADD  DEFAULT ((0)) FOR [ParentRegionID]
GO
ALTER TABLE [dbo].[BillInfo] ADD  DEFAULT ((0)) FOR [ChargeCash]
GO
ALTER TABLE [dbo].[BillInfo] ADD  DEFAULT ((0)) FOR [ChargeBalance]
GO
ALTER TABLE [dbo].[BillInfo] ADD  DEFAULT ((0)) FOR [ChargeOther]
GO
ALTER TABLE [dbo].[ConditionOSD] ADD  CONSTRAINT [DF__Condition__Displ__3E1D39E1]  DEFAULT ((1)) FOR [DisplayCount]
GO
ALTER TABLE [dbo].[GroupInfo] ADD  CONSTRAINT [DF_GroupInfo_Status]  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [dbo].[ICCardGroup] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [dbo].[ICCardInfo] ADD  CONSTRAINT [DF__ICCardInf__Paren__3C69FB99]  DEFAULT ((0)) FOR [ParentICTableID]
GO
ALTER TABLE [dbo].[OrderProduct] ADD  CONSTRAINT [DF_OrderProduct_Status]  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [dbo].[ProductInfo] ADD  CONSTRAINT [DF__ProductIn__Limit__1273C1CD]  DEFAULT ((0)) FOR [Limit_Flag]
GO
ALTER TABLE [dbo].[SMSNote] ADD  CONSTRAINT [DF_SMSNote_status]  DEFAULT ((0)) FOR [status]
GO
ALTER TABLE [dbo].[UserInfo] ADD  CONSTRAINT [DF__UserInfo__Status__31EC6D26]  DEFAULT ((1)) FOR [Active]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'01 0001 0001 0001
   0A 000A 000A 000A
   
   发给CA的数据' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AddressRegion', @level2type=N'COLUMN',@level2name=N'Layer'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1 有效
   0 无效' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AddressRegion', @level2type=N'COLUMN',@level2name=N'Active'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'客户区域划分，用户控制“区域锁定”' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AddressRegion'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'授权信息表' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AuthInfo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'扣费记录表' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AutoSubtractFee'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系统码表' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BaseData'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'操作员' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BatchBill', @level2type=N'COLUMN',@level2name=N'Creator'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'操作时间' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BatchBill', @level2type=N'COLUMN',@level2name=N'CreateTime'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'收费项目' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BatchBillDetail', @level2type=N'COLUMN',@level2name=N'ItemType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'数量包括（金额，数量等）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BatchBillDetail', @level2type=N'COLUMN',@level2name=N'ItemQuantity'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'按批次缴费' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BatchOrderProduct'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'发票编号' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BillDetail', @level2type=N'COLUMN',@level2name=N'BillID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1:开户;
   2:定购IC卡;
   3:定购机顶盒;
   4:产品;
   5:电子钱包;
   6:报停;' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BillDetail', @level2type=N'COLUMN',@level2name=N'PriceType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'发票明细' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BillDetail'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'发票编号' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BillInfo', @level2type=N'COLUMN',@level2name=N'BillID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'重打发票   被重打发票的编号' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BillInfo', @level2type=N'COLUMN',@level2name=N'BillNumber'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'按客户对户号规则需求存放用户标识' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BillInfo', @level2type=N'COLUMN',@level2name=N'CustomerNumber'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'操作员' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BillInfo', @level2type=N'COLUMN',@level2name=N'Creator'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'操作时间' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BillInfo', @level2type=N'COLUMN',@level2name=N'CreateTime'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'发票主表' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BillInfo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1 有效
   0 无效' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BroadcasterInfo', @level2type=N'COLUMN',@level2name=N'Active'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1 DX CAS4
   2 DX CAS5' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CAInstance', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1 有效
   0 无效' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CertificateType', @level2type=N'COLUMN',@level2name=N'Active'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'证件类型' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CertificateType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'更换设备' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ChangeEquipment'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'过户' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ChangeOwner'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'主键' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ConditionAddress', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'条件OSD
   OSD = 0x05,
   条件MAIL
   MAIL = 0x06,
   条件紧急广播
   EMERGENCY_BROADCAST = 0X07,
   条件限播
   LIMIT = 0X08,
   条件节目搜索
   SEARCH_PROGRAN = 0X09,
    条件授权
   AUTH = 0X0A,
   网络异常解锁
   NET_ERROR_UNLOCK = 0X0B,
   系统(数据)异常解锁 
   SYSTEM_ERROR_UNLOCK = 0X0C,' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ConditionAddress', @level2type=N'COLUMN',@level2name=N'ConditionType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'CAS 版本 CASInstance外键' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ConditionAddress', @level2type=N'COLUMN',@level2name=N'CASVersion'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'CAS返回的ID,删除命令时使用' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ConditionAddress', @level2type=N'COLUMN',@level2name=N'CASID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'发送给CAS的操作员名称' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ConditionAddress', @level2type=N'COLUMN',@level2name=N'OperatorName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'起始时间' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ConditionAddress', @level2type=N'COLUMN',@level2name=N'StartTime'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'结束时间' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ConditionAddress', @level2type=N'COLUMN',@level2name=N'EndTime'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'是否有效' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ConditionAddress', @level2type=N'COLUMN',@level2name=N'Active'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'条件基础信息表' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ConditionAddress'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'条件邮件' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ConditionMail'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'条件屏显' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ConditionOSD'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'排序列   当第一个条件的时候 不显示 IsAnd字段' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ConditionWithKey', @level2type=N'COLUMN',@level2name=N'Ordering'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'并且
   AND = 0X80,
   或者
   OR = 0X81,' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ConditionWithKey', @level2type=N'COLUMN',@level2name=N'IsAnd'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'条件寻址类型:
   按卡号寻址
   CARD_NUMBER = 0X30,
   按地址码寻址
   ADDRESS = 0X31,
   按用户组寻址
   CARD_GROUP = 0X32,
   LCO号
   LCO_NUMBER = 0X33,' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ConditionWithKey', @level2type=N'COLUMN',@level2name=N'ConditionByType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'比较符:
   小于
   LT = 0X70,
   小于等于
   LE= 0X71,
   大于
   GT = 0X72,
   大于等于
   GE = 0X73,
    等于
   EQ = 0X74,
   不等于寻址命令间：（取值范围：0X80~0X8F）
   NE = 0X75,' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ConditionWithKey', @level2type=N'COLUMN',@level2name=N'OperateType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'条件寻址存放Key信息' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ConditionWithKey'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'关联ConditionBase表主键ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ConditionWithProducts', @level2type=N'COLUMN',@level2name=N'ConditionID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'产品编号' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ConditionWithProducts', @level2type=N'COLUMN',@level2name=N'ProductID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'条件寻址存放与产有关的信息' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ConditionWithProducts'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'关联ConditionBase表主键ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ConditionWithPrograms', @level2type=N'COLUMN',@level2name=N'ConditionID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'节目编号' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ConditionWithPrograms', @level2type=N'COLUMN',@level2name=N'ProgramID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'条件寻址存放与节目有关的信息' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ConditionWithPrograms'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'按客户对户号规则需求存放用户标识' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CustomerInfo', @level2type=N'COLUMN',@level2name=N'CustomerNumber'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'手机号码' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CustomerInfo', @level2type=N'COLUMN',@level2name=N'MobilePhoneNumber'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'账单地址' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CustomerInfo', @level2type=N'COLUMN',@level2name=N'BillingAddress'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'E mail 地址' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CustomerInfo', @level2type=N'COLUMN',@level2name=N'EmailID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'订购合同号' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CustomerInfo', @level2type=N'COLUMN',@level2name=N'SubscriptionContractNumber'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'+ 多收客户的钱
   - 少收客户的钱' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CustomerInfo', @level2type=N'COLUMN',@level2name=N'Adjust'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'0:未激活
   1:已激活
   2:销户' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CustomerInfo', @level2type=N'COLUMN',@level2name=N'Status'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1 有效
   0 无效' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CustomerInfo', @level2type=N'COLUMN',@level2name=N'Active'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'客户信息' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CustomerInfo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1:定购;
   2:退订;
   3:异常处理;
   ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CustomerInit', @level2type=N'COLUMN',@level2name=N'OperateType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'开户' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CustomerInit'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1:定购;
   2:退订;
   3:异常处理;
   4:更换设备
   ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CustomerInstal', @level2type=N'COLUMN',@level2name=N'OperateType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'0:无效
   1:有效
   2:退订
   3:异常处理' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CustomerInstal', @level2type=N'COLUMN',@level2name=N'Status'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'开户' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CustomerInstal'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'启用状态' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CustTypeInfo', @level2type=N'COLUMN',@level2name=N'Active'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'客户类型' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CustTypeInfo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'0：运营商
   1：营业厅' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Department', @level2type=N'COLUMN',@level2name=N'DepartmentType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1 有效
   0 无效' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Department', @level2type=N'COLUMN',@level2name=N'Active'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'组织机构管理' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Department'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'部门区域关系' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Department_Region_Relation'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'客户编号' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DueRemain', @level2type=N'COLUMN',@level2name=N'CustomerID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'客户名称' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DueRemain', @level2type=N'COLUMN',@level2name=N'CustomerName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'联系电话' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DueRemain', @level2type=N'COLUMN',@level2name=N'Tel'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'消息内容' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DueRemain', @level2type=N'COLUMN',@level2name=N'MsgContent'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'IC卡主键' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DueRemain', @level2type=N'COLUMN',@level2name=N'ICTableID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ic卡内部卡号' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DueRemain', @level2type=N'COLUMN',@level2name=N'InternalNumber'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ic卡扩展卡号' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DueRemain', @level2type=N'COLUMN',@level2name=N'ExternalNumber'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'消息创建时间' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DueRemain', @level2type=N'COLUMN',@level2name=N'CreateTime'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'IC卡 收视到期时间' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DueRemain', @level2type=N'COLUMN',@level2name=N'MaxEndDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'最后一次提前催费发送时间' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DueRemain', @level2type=N'COLUMN',@level2name=N'SendTimeBefore'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'提前   已经催费次数' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DueRemain', @level2type=N'COLUMN',@level2name=N'SendTimesBefore'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'提前催费状态  是否催费成功' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DueRemain', @level2type=N'COLUMN',@level2name=N'StateBefore'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'最后一次 延期催费发送时间' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DueRemain', @level2type=N'COLUMN',@level2name=N'SendTimeAfter'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'延后   已经催费次数' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DueRemain', @level2type=N'COLUMN',@level2name=N'SendTimesAfter'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'延后催费状态' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DueRemain', @level2type=N'COLUMN',@level2name=N'StateAfter'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'客户是否已经续费' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DueRemain', @level2type=N'COLUMN',@level2name=N'IsRenew'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'提前催费' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DueRemain'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1:定购;
   2:退订;
   3:异常处理;
   ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'E_Notecase', @level2type=N'COLUMN',@level2name=N'OperateType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'电子钱包充值' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'E_Notecase'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ic卡主键' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EasyPayInfo', @level2type=N'COLUMN',@level2name=N'ICTableID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'IC卡内部卡号' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EasyPayInfo', @level2type=N'COLUMN',@level2name=N'InternalNumber'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'充值卡号' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EasyPayInfo', @level2type=N'COLUMN',@level2name=N'RechargeNumber'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'信息创建时间' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EasyPayInfo', @level2type=N'COLUMN',@level2name=N'CreateDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'按金额充值  的充值金额' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EasyPayInfo', @level2type=N'COLUMN',@level2name=N'Cash'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'本次充值使用金额' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EasyPayInfo', @level2type=N'COLUMN',@level2name=N'UseCash'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'按金额充值  剩余金额  ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EasyPayInfo', @level2type=N'COLUMN',@level2name=N'Balance'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'充值类型 1 金额  2产品 3上门收费' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EasyPayInfo', @level2type=N'COLUMN',@level2name=N'RechargeTypes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'当前充值记录状态' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EasyPayInfo', @level2type=N'COLUMN',@level2name=N'State'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'备注' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EasyPayInfo', @level2type=N'COLUMN',@level2name=N'Remark'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'短信充值信息记录' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EasyPayInfo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1 有效
   0 无效' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EasyPayOrg', @level2type=N'COLUMN',@level2name=N'Active'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'显示时间' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EMMGFinger', @level2type=N'COLUMN',@level2name=N'ShowTime'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'隐藏时间' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EMMGFinger', @level2type=N'COLUMN',@level2name=N'StopTime'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'颜色类型(1-16位, 2-24位,3-RGB)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EMMGFinger', @level2type=N'COLUMN',@level2name=N'ColorType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'显隐标志 1显示2隐藏' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EMMGFinger', @level2type=N'COLUMN',@level2name=N'OvertFlag'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'EMMG指纹显示' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EMMGFinger'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'0:订购
   1:预存' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FeePackage', @level2type=N'COLUMN',@level2name=N'FeeModel'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'0:未发布
   1:已发布' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FeePackage', @level2type=N'COLUMN',@level2name=N'Status'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'套餐管理' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FeePackage'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'关联套餐主表' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FeePackageEquipment', @level2type=N'COLUMN',@level2name=N'PackageID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'设备套餐从表 ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FeePackageEquipment'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'关联套餐主表' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FeePackageOther', @level2type=N'COLUMN',@level2name=N'PackageID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'其他业务套餐从表' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FeePackageOther'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'关联套餐主表' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FeePackageProduct', @level2type=N'COLUMN',@level2name=N'PackageID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'0 按月 1按天' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FeePackageProduct', @level2type=N'COLUMN',@level2name=N'Unit'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'节目包套餐从表' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FeePackageProduct'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'颜色类型(1-16位, 2-24位,3-RGB)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ForceOSD', @level2type=N'COLUMN',@level2name=N'ColorType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'所占屏幕比例(80~100)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ForceOSD', @level2type=N'COLUMN',@level2name=N'Ratio'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'显示时间' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ForceOSD', @level2type=N'COLUMN',@level2name=N'ShowTime'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'隐藏时间' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ForceOSD', @level2type=N'COLUMN',@level2name=N'StopTime'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'框体透明度(0~100  0表示不透明，100表示全透明)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ForceOSD', @level2type=N'COLUMN',@level2name=N'Clarity'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'强制OSD' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ForceOSD'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'是否是公用权限(即可以下发的权限组)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GroupInfo', @level2type=N'COLUMN',@level2name=N'IsPublic'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'权限组' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GroupInfo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'IC卡分组' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ICCardGroup'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'0:正常;
   1:高级;
   2:实时;
   3:超高;' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ICCardInfo', @level2type=N'COLUMN',@level2name=N'Priority'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'0:订购
   1:预存' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ICCardInfo', @level2type=N'COLUMN',@level2name=N'CurrentFeeModel'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'0:订购
   1:预存' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ICCardInfo', @level2type=N'COLUMN',@level2name=N'NextFeeModel'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'0：注销；
   1：正常；
   2：报停；
   3：未激活；' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ICCardInfo', @level2type=N'COLUMN',@level2name=N'Status'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1 有效
   0 无效' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ICCardInfo', @level2type=N'COLUMN',@level2name=N'Active'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'IC卡信息' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ICCardInfo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'机卡配对 用于cas6.*' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ICSTBPairing'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'事件名称' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LogInfoManagement', @level2type=N'COLUMN',@level2name=N'EventType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'邮件管理' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MailInfo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'未授权节目观看时间' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'NoAuthorizeWatchTime'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'未授权观看关联节目表' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'NoAuthWatchProgramRelation'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1:定购;
   2:退订;
   3:异常处理;
   ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'OrderCard', @level2type=N'COLUMN',@level2name=N'OperateType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'订购IC卡' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'OrderCard'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1:定购;
   2:退订;
   3:异常处理;
   ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'OrderFeePackage', @level2type=N'COLUMN',@level2name=N'OperateType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'0:无效
   1:有效' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'OrderFeePackage', @level2type=N'COLUMN',@level2name=N'Status'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'套餐订购' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'OrderFeePackage'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'0:无效
   1:有效' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'OrderPrestore', @level2type=N'COLUMN',@level2name=N'Status'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1:订购;2:短信充值;3:预存;' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'OrderPrestore', @level2type=N'COLUMN',@level2name=N'RenewOriginateType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'合约信息表' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'OrderPrestore'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1:定购;
   2:退订;
   3:异常处理;
   ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'OrderProduct', @level2type=N'COLUMN',@level2name=N'OperateType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1:订购;2:短信充值;3:预存;' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'OrderProduct', @level2type=N'COLUMN',@level2name=N'RenewOriginateType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'0无效 1有效' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'OrderProduct', @level2type=N'COLUMN',@level2name=N'Status'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'订购产品' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'OrderProduct'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'余额模式
   记录IC卡下月订购的节目包信息' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'OrderProductPlan'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1:定购;
   2:退订;
   3:异常处理;
   ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'OrderSTB', @level2type=N'COLUMN',@level2name=N'OperateType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'订购机顶盒' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'OrderSTB'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'OSD管理' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'OSDInfo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'权限表' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Permit'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'权限组权限设置' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PermitGroupSetting'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'PPV节目事件' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PPVEventInfo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1
   2
   3
   4' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PPVProviderInfo', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1 有效
   0 无效' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PPVProviderInfo', @level2type=N'COLUMN',@level2name=N'Active'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'PPV供应商信息' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PPVProviderInfo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1:开户;
   2:定购IC卡;
   3:定购机顶盒;
   4:母卡定购产品;
   5:电子钱包;
   6:报停;
   7:子卡定购产品' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PreferentialTactic', @level2type=N'COLUMN',@level2name=N'PriceType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'百分比' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PreferentialTactic', @level2type=N'COLUMN',@level2name=N'Preferential'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'优惠策略' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PreferentialTactic'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'电子钱包价格' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PriceE_Notecase'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'0:未发布
   1:已发布' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PriceEquipment', @level2type=N'COLUMN',@level2name=N'Status'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'设备定价' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PriceEquipment'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1:开户;
   2:定购IC卡;
   3:定购机顶盒;
   4:产品;
   5:电子钱包;
   6:报停;' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PriceOther', @level2type=N'COLUMN',@level2name=N'PriceType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'0:未发布
   1:已发布' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PriceOther', @level2type=N'COLUMN',@level2name=N'Status'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'业务定价' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PriceOther'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'0:未发布
   1:已发布' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PriceProduct', @level2type=N'COLUMN',@level2name=N'Status'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'节目包价格' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PriceProduct'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1 有效
   0 无效' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProductInfo', @level2type=N'COLUMN',@level2name=N'Active'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'产品（节目包）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProductInfo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'节目包和节目关系表' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProductProgramRelation'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'0, //屏幕左上方
   1,  //屏幕右上方
   2,  //屏幕左下方
   3, //屏幕右下方
   4, //在上述位置随机显示' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProgramFingerprintFor4', @level2type=N'COLUMN',@level2name=N'DisplayPositionCode'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'节目指纹信息CAS4' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProgramFingerprintFor4'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'0, //屏幕左上方
   1,  //屏幕右上方
   2,  //屏幕左下方
   3, //屏幕右下方
   4, //在上述位置随机显示
   0xFF, //屏幕设定显示位置 5.1版' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProgramFingerprintFor5', @level2type=N'COLUMN',@level2name=N'DisplayPositionCode'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'按坐标显示 位置X' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProgramFingerprintFor5', @level2type=N'COLUMN',@level2name=N'PositionX'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'按坐标显示 位置Y' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProgramFingerprintFor5', @level2type=N'COLUMN',@level2name=N'PositionY'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'节目指纹信息CAS5' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProgramFingerprintFor5'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'4, //在上述位置随机显示
   0xFF, //屏幕设定显示位置 5.1版' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProgramFingerprintFor6', @level2type=N'COLUMN',@level2name=N'DisplayPositionCode'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'按坐标显示 位置X' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProgramFingerprintFor6', @level2type=N'COLUMN',@level2name=N'PositionX'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'按坐标显示 位置Y' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProgramFingerprintFor6', @level2type=N'COLUMN',@level2name=N'PositionY'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1 = bit16
   2 = bit24
   3 = argb' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProgramFingerprintFor6', @level2type=N'COLUMN',@level2name=N'ColorTypeCode'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'节目指纹信息CAS6' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProgramFingerprintFor6'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1-9' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProgramInfo', @level2type=N'COLUMN',@level2name=N'VisibleLevel'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'0:ppc
   1:ppv' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProgramInfo', @level2type=N'COLUMN',@level2name=N'ProgramTypeCode'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1 有效
   0 无效' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProgramInfo', @level2type=N'COLUMN',@level2name=N'Active'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'节目信息' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProgramInfo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'IC卡供应商
   stb供应商' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProviderInfo', @level2type=N'COLUMN',@level2name=N'ProviderTypeCode'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1 有效
   0 无效' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProviderInfo', @level2type=N'COLUMN',@level2name=N'Active'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'供应商信息' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProviderInfo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'来自供应商' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'STBInfo', @level2type=N'COLUMN',@level2name=N'ModelNumber'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'0：注销(更换、异常处理)；
   1：正常(卖出)；
   2：入库；' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'STBInfo', @level2type=N'COLUMN',@level2name=N'Status'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1 有效
   0 无效' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'STBInfo', @level2type=N'COLUMN',@level2name=N'Active'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'机顶盒信息' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'STBInfo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1:定购;
   2:退订;
   3:异常处理;
   ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Stop', @level2type=N'COLUMN',@level2name=N'OperateType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'0:OneTime;1:Month' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Stop', @level2type=N'COLUMN',@level2name=N'PauseCalType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'报开报停业务' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Stop'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ps:数据库版本号 
        调为标准' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SystemSetting'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'0:未发布
   1:已发布' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TacticPreferential', @level2type=N'COLUMN',@level2name=N'Status'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'优惠策略主表' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TacticPreferential'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'收费记录' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserCost'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'0：男；
   1：女；
   2：未指定；' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserInfo', @level2type=N'COLUMN',@level2name=N'Sex'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'0:禁用
   1:启用' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserInfo', @level2type=N'COLUMN',@level2name=N'Active'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'操作员' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserInfo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'用户编号' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserInfo_Group_Relation', @level2type=N'COLUMN',@level2name=N'UserID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'组编号' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserInfo_Group_Relation', @level2type=N'COLUMN',@level2name=N'GroupID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'用户与组关系' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserInfo_Group_Relation'
GO
USE [master]
GO
ALTER DATABASE [SMSWeb] SET  READ_WRITE 
GO
