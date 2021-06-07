/*创建三个表*/
CREATE TABLE Reader /*读者*/
(
	Sno int PRIMARY KEY,
	Sname CHAR(40) NOT NULL,
);

CREATE TABLE Book  /*书籍*/
(
	Bno int PRIMARY KEY,
	Bname CHAR(20) NOT NULL,
	Bstate CHAR(20) CHECK(Bstate IN('在架','借出'))  /*状态*/
);

CREATE TABLE Borrow  /*借阅*/
(
	Bno int NOT NULL primary key identity(1,1),/*书号*/
	Sno int NOT NULL,/*借书证号*/
	Bname CHAR(20) NOT NULL,
	Sname CHAR(40) NOT NULL,
	BoTime DATE NOT NULL,
	ReTime DATE NOT NULL,/*还书时间一个月以后*/
	FOREIGN KEY(Sno)REFERENCES Reader(Sno),
	FOREIGN KEY(Bno)REFERENCES Book(Bno)
);


/*存储过程sf_borrow,书号、借书证号，借书时间作为参数，归还日期一个月后*/
Go
CREATE PROCEDURE sf_borrow(@Bno int,@Sno int,@BoTime date)
AS
BEGIN
	SET IDENTITY_INSERT Borrow ON
	INSERT INTO Borrow(Bno,Sno,Bname,Sname,BoTime,ReTime)
	VALUES(@Bno,@Sno,(select Bname from BOOK where Bno =@Bno),(select Sname from Reader where Sno =@Sno),@BoTime,dateadd(month,1,@BoTime))
END;


/*insert  触发器*/
GO
CREATE TRIGGER Tri_Insert
ON Borrow FOR INSERT AS 
BEGIN
/*从insert的表中收集信息*/
declare @Bno char(9) set @Bno =(select Bno from inserted)
declare @Sno char(9) set @Sno =(select Sno from inserted)
declare @BoTime char(9) set @BoTime =(select BoTime from inserted)
declare @Bname char(9) set @Bname =(select Bname from inserted)
declare @Sname char(9) set @Sname =(select Sname from inserted)
print(@Bno)
print(@Sno)
print(@BoTime)
print(@Bname)
print(@Sname)
	/*书已被借走，不可借阅*/
	IF((select Bstate from BOOK where Bno =@Bno)='借出' )
		BEGIN
			rollback
			print '此书已被借走，不可借阅'
		END
	IF((select Bstate from BOOK where Bno =@Bno)='在架' )
		BEGIN
			print '借书成功'
				/*更改BOOK表中的Bstate*/
			UPDATE BOOK
			SET  Bstate='借出'
			WHERE  Bno =@Bno
		END
END

GO
/*存储过程还书sf_return,根据书号删除书籍信息*/
CREATE PROCEDURE sf_return  
@BNo char(20) AS
BEGIN
	DELETE FROM BORROW
	WHERE Bno = @Bno
	END
	
/*删除操作触发器，借阅信息表进行删除操作时，根据书号，改变“状态”字段发生变化*/
GO
CREATE TRIGGER Tri_Delete ON Borrow FOR DELETE AS
BEGIN 
declare @Bno char(10) set @Bno =(select Bno from deleted)
	BEGIN 
		UPDATE BOOK SET Bstate ='在架' WHERE Bno=@Bno
	END	
END