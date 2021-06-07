/*����������*/
CREATE TABLE Reader /*����*/
(
	Sno int PRIMARY KEY,
	Sname CHAR(40) NOT NULL,
);

CREATE TABLE Book  /*�鼮*/
(
	Bno int PRIMARY KEY,
	Bname CHAR(20) NOT NULL,
	Bstate CHAR(20) CHECK(Bstate IN('�ڼ�','���'))  /*״̬*/
);

CREATE TABLE Borrow  /*����*/
(
	Bno int NOT NULL primary key identity(1,1),/*���*/
	Sno int NOT NULL,/*����֤��*/
	Bname CHAR(20) NOT NULL,
	Sname CHAR(40) NOT NULL,
	BoTime DATE NOT NULL,
	ReTime DATE NOT NULL,/*����ʱ��һ�����Ժ�*/
	FOREIGN KEY(Sno)REFERENCES Reader(Sno),
	FOREIGN KEY(Bno)REFERENCES Book(Bno)
);


/*�洢����sf_borrow,��š�����֤�ţ�����ʱ����Ϊ�������黹����һ���º�*/
Go
CREATE PROCEDURE sf_borrow(@Bno int,@Sno int,@BoTime date)
AS
BEGIN
	SET IDENTITY_INSERT Borrow ON
	INSERT INTO Borrow(Bno,Sno,Bname,Sname,BoTime,ReTime)
	VALUES(@Bno,@Sno,(select Bname from BOOK where Bno =@Bno),(select Sname from Reader where Sno =@Sno),@BoTime,dateadd(month,1,@BoTime))
END;


/*insert  ������*/
GO
CREATE TRIGGER Tri_Insert
ON Borrow FOR INSERT AS 
BEGIN
/*��insert�ı����ռ���Ϣ*/
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
	/*���ѱ����ߣ����ɽ���*/
	IF((select Bstate from BOOK where Bno =@Bno)='���' )
		BEGIN
			rollback
			print '�����ѱ����ߣ����ɽ���'
		END
	IF((select Bstate from BOOK where Bno =@Bno)='�ڼ�' )
		BEGIN
			print '����ɹ�'
				/*����BOOK���е�Bstate*/
			UPDATE BOOK
			SET  Bstate='���'
			WHERE  Bno =@Bno
		END
END

GO
/*�洢���̻���sf_return,�������ɾ���鼮��Ϣ*/
CREATE PROCEDURE sf_return  
@BNo char(20) AS
BEGIN
	DELETE FROM BORROW
	WHERE Bno = @Bno
	END
	
/*ɾ��������������������Ϣ�����ɾ������ʱ��������ţ��ı䡰״̬���ֶη����仯*/
GO
CREATE TRIGGER Tri_Delete ON Borrow FOR DELETE AS
BEGIN 
declare @Bno char(10) set @Bno =(select Bno from deleted)
	BEGIN 
		UPDATE BOOK SET Bstate ='�ڼ�' WHERE Bno=@Bno
	END	
END