-- Tabela przedstawiaj�ca nazwe produktu, rok produkcji oraz cen� katalogow� od najmniejszej do najwi�kszej
	Use [Bike_store]
	Select 
			product_name
			, model_year
			,list_price
	from production.products
	Order by list_price

-- Wszystkie produkty wyprodukowane w 2018 roku marki Trek wraz z categories ID posortowane od najwi�kszej do najmniejszej oraz alfabetycznie
	Select
			product_name
			,model_year
			,brand_id
			,list_price
	from production.products
	where product_name like 'Trek%'
	and model_year = 2018
	Order by list_price desc, product_name

-- Tabela przedstawiaj�ce zam�wione przedmioty przez klient�w wraz z cen� katalogow� oraz warto�ci� zam�wienia
	Select
			order_id
			,product_id
			,list_price
			,Cast((list_price*quantity)as money) as Order_Value
	from sales.order_items
-- Tabela przedstawiaj�ce zam�wione przedmioty przez klient�w wraz z cen� katalogow�, warto�ci� zam�wienia oraz rabatem wyra�onym w kwocie ca�kowitej
	Select
			order_id
			,product_id
			,list_price
			,Cast((list_price*quantity)as money) as Order_Value
			,Cast((list_price*quantity *discount)as money) as Discount
	from sales.order_items
	Order by kwota_rabatu desc

--Najwi�ksza oraz najmniejsza warto�� zam�wienia ka�dego produktu rower�w
	Select 
			product_name
			,Cast(Min(OI.list_price*OI.quantity)as money) as The_Lowest_Order
			,Cast(Max(OI.list_price*OI.quantity)as money) as The_Biggest order
	from sales.order_items as OI
	inner join production.products as PP
	on OI.product_id = PP.product_id
	Group by product_name
-- Tabela pokazuj�c� z kt�rych miast klienci najcz�ciej zamwiaj� artyku�y
	Select 
			city
			,count (customer_id) as Clients
	From sales.customers
	group by city
	order by Liczba_klient�w desc
-- Tabela pokazuj�ca z kt�rych stan�w klienci najcz�ciej zamwiaj� artyku�y
	Select 
			state
			,count (customer_id) as Clients
	From sales.customers
	group by state
	order by Liczba_klient�w desc
-- Liczba zam�wie� dla ka�dego sklepu
	Select
			store_name
			,state
			,Count(order_id) as Orders
	From sales.stores as ss
	inner join sales.orders as so
	on ss.store_id = so.store_id
	Group by store_name, state
	Order by Liczba_Zam�wie� desc
-- Liczba pracownik�w ka�dego sklepu
	Select
			store_name
			,state
			,Count(staff_id) as Employee_Amount
	from sales.staffs as sst
	inner join sales.stores as sso
	on sst.store_id = sso.store_id
	Group by store_name, state
-- Liczba sprzeda�y ka�dego pracownika w podziale na sklepy
	Select
			store_name
			,state
			,so.staff_id
			,first_name
			,last_name
			,COUNT(order_id) as Orders
	From sales.orders so
	inner join sales.stores as sst
	on so.store_id = sst.store_id
	inner join sales.staffs as staff
	on sst.store_id = staff.store_id
	Group By store_name,state,first_name,last_name,so.staff_id
-- Liczba produkt�w przypadaj�ca na ka�dy sklep
	Select
			store_name
			,product_name
			,Sum(quantity) as Quantity
	From production.products as product
	inner join production.stocks as stock
	on product.product_id = stock.product_id
	inner join sales.stores as store
	on stock.store_id = stock.store_id
	Group by store_name,product_name
	order by store_name
--Warto�� magazynowa ka�dego sklepu
	Select
			store_name
			,Sum(quantity*list_price) as Stock_Value
	From production.products as product
	inner join production.stocks as stock
	on product.product_id = stock.product_id
	inner join sales.stores as store
	on stock.store_id = stock.store_id
	Group by store_name
	-- Wszystkie op�nione zam�wienia

	Select
			store_id
			,order_id
			,customer_id
			,order_date
			,required_date
			,shipped_date
			,DATEDIFF(Day,required_date,shipped_date) as Delay
	From sales.orders
	where required_date < shipped_date
-- Warto�ci op�nionych zam�wie�

	Select
			store_id
			,soi.order_id
			,customer_id
			,order_date
			,required_date
			,shipped_date
			,DATEDIFF(Day,required_date,shipped_date) as Delay
			,(quantity*list_price) as Sum_Order
	From sales.orders as so
	inner join sales.order_items as soi
	on so.order_id = soi.order_id
	where required_date < shipped_date
-- Sprzeda� jaka mia�a miejsce ka�dego miesi�ca
	Select
			DATEPART(Year,so.shipped_date) as Year
			,DATEPART(month,so.shipped_date) as Month
			,Sum(quantity*list_price) as Suma
	From sales.orders as so
	inner join sales.order_items as soi
	on so.order_id = soi.order_id
	where so.shipped_date is not null
	Group by DATEPART(Year,so.shipped_date)
			,DATEPART(month,so.shipped_date)
	Order by Year,Month
-- Sprzeda� jaka mia�a miejsce ka�dego miesi�ca w podziale na sklepy
	Select	
			store_name
			,DATEPART(Year,so.shipped_date) as Year
			,DATEPART(month,so.shipped_date) as Month
			,Sum(quantity*list_price) as Sum
	From sales.orders as so
	inner join sales.order_items as soi
	on so.order_id = soi.order_id
	inner join sales.stores as ss
	on so.store_id = ss.store_id
	where so.shipped_date is not null
	Group by DATEPART(Year,so.shipped_date)
			,DATEPART(month,so.shipped_date)
			,store_name
	Order by Year,Month,store_name

-- CTE pokazuj�ce warto�ci sprzeda�y produkt�w kategorii 1,2 oraz 3 dla ka�dego sklepu

With
Indeks_1 as (
	Select 
			ss.store_name
			,SUM(soi.quantity) as Quantity_Indeks_1
			,Sum(soi.quantity * soi.list_price) as Sales_Category_1
	From production.products as pp
	inner join production.categories as pc
	on pp.category_id = pc.category_id
	inner join sales.order_items as soi
	on pp.product_id = soi.product_id
	inner join sales.orders as so
	on soi.order_id = so.order_id
	inner join sales.stores as ss
	on so.store_id = ss.store_id
	where pc.category_id = 1
	Group by ss.store_name
			),
Indeks_2 as (
	Select 
			ss.store_name
			,SUM(soi.quantity) as Quantity_Indeks_2
			,Sum(soi.quantity * soi.list_price) as Sales_Category_2
	From production.products as pp
	inner join production.categories as pc
	on pp.category_id = pc.category_id
	inner join sales.order_items as soi
	on pp.product_id = soi.product_id
	inner join sales.orders as so
	on soi.order_id = so.order_id
	inner join sales.stores as ss
	on so.store_id = ss.store_id
	where pc.category_id = 2
	Group by ss.store_name
				),
Indeks_3 as		(
		Select 
			ss.store_name
			,SUM(soi.quantity) as Quantity_Indeks_3
			,Sum(soi.quantity * soi.list_price) as Sales_Category_3
	From production.products as pp
	inner join production.categories as pc
	on pp.category_id = pc.category_id
	inner join sales.order_items as soi
	on pp.product_id = soi.product_id
	inner join sales.orders as so
	on soi.order_id = so.order_id
	inner join sales.stores as ss
	on so.store_id = ss.store_id
	where pc.category_id = 3
	Group by ss.store_name
				)
	Select 
			Indeks_1.store_name
			,Indeks_1.Quantity_Indeks_1
			,Indeks_2.Quantity_Indeks_2
			,Indeks_3.Quantity_Indeks_3
			,Indeks_1.Sales_Category_1
			,Indeks_2.Sales_Category_2
			,Indeks_3.Sales_Category_3		
	from Indeks_1
	Inner join Indeks_2
	on Indeks_1.store_name = Indeks_2.store_name
	inner join Indeks_3
	on Indeks_2.store_name = Indeks_3.store_name


