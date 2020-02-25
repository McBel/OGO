Процедура УстановитьПараметрыЗагрузкиИзФайлаВТЧ(Параметры) Экспорт
	// TODO:
	Параметры.ИмяМакетаСШаблоном = "ЗагрузкаИзФайлаПрейскурант";
КонецПроцедуры
Процедура СопоставитьЗагружаемыеДанные(АдресЗагруженныхДанных, АдресКопииТабличнойЧасти, СписокНеоднозначностей, ИмяОбъектаСопоставления, ДополнительныеПараметры) Экспорт
	// TODO:
	ПерваяТаблица = ПолучитьИзВременногоХранилища(АдресЗагруженныхДанных);
	ВтораяТаблица = ПолучитьИзВременногоХранилища(АдресКопииТабличнойЧасти);
	
	//МВТ = Новый МенеджерВременныхТаблиц();
	//{{КОНСТРУКТОР_ЗАПРОСА_С_ОБРАБОТКОЙ_РЕЗУЛЬТАТА
	// Данный фрагмент построен конструктором.
	// При повторном использовании конструктора, внесенные вручную изменения будут утеряны!
	
	Запрос = Новый Запрос;
	//Запрос.МенеджерВременныхТаблиц.Таблицы.
	Запрос.Текст =
		"ВЫБРАТЬ
		|	МВременнаяТаблица.COST КАК COST,
		|	ВЫРАЗИТЬ(МВременнаяТаблица.КодВидаРабот КАК СТРОКА(13)) КАК Поле1,
		|	ВЫРАЗИТЬ(МВременнаяТаблица.D_START КАК СТРОКА(18)) КАК D_START,
		|	ВЫРАЗИТЬ(МВременнаяТаблица.CODE КАК СТРОКА(13)) КАК CODE,
		|	ВЫРАЗИТЬ(МВременнаяТаблица.V_RABOT КАК СТРОКА(13)) КАК V_RABOT
		|ПОМЕСТИТЬ ВременнаяТаблица
		|ИЗ
		|	&МВременнаяТаблица КАК МВременнаяТаблица
		|ГДЕ
		|	МВременнаяТаблица.D_START ПОДОБНО &ДатаУстановкицен
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ВложенныйЗапрос.COST КАК COST,
		|	ВложенныйЗапрос.Ссылка КАК ВРСс,
		|	ВложенныйЗапрос.D_START КАК D_START,
		|	ВложенныйЗапрос.CODE КАК CODE,
		|	ВложенныйЗапрос.V_RABOT КАК V_RABOT
		|ИЗ
		|	(ВЫБРАТЬ
		|		ВременнаяТаблица.COST КАК COST,
		|		ВидыРабот.Ссылка КАК Ссылка,
		|		ВременнаяТаблица.D_START КАК D_START,
		|		ВременнаяТаблица.CODE КАК CODE,
		|		ВременнаяТаблица.V_RABOT КАК V_RABOT
		|	ИЗ
		|		ВременнаяТаблица КАК ВременнаяТаблица
		|			ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.ВидыРабот КАК ВидыРабот
		|			ПО (ВидыРабот.Код = ВременнаяТаблица.Поле1)) КАК ВложенныйЗапрос";
		
	
	Запрос.УстановитьПараметр("ВустаяСсылкаНаВР", Справочники.ВидыРабот.ПустаяСсылка());
	Запрос.УстановитьПараметр("МВременнаяТаблица", ПерваяТаблица);
	Запрос.УстановитьПараметр("ДатаУстановкицен", Строка(ДополнительныеПараметры.Дата));
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		// Вставить обработку выборки ВыборкаДетальныеЗаписи
		НСтрока = ВтораяТаблица.Добавить();
		НСтрока.ВидРабот =  ВыборкаДетальныеЗаписи.ВРСс;
		НСтрока.Цена = ВыборкаДетальныеЗаписи.COST;
		НСтрока.V_RABOT = ВыборкаДетальныеЗаписи.V_RABOT;
		НСтрока.CODE = ВыборкаДетальныеЗаписи.CODE;
		НСтрока.D_START = ВыборкаДетальныеЗаписи.D_START;
	КонецЦикла;
	
	//}}КОНСТРУКТОР_ЗАПРОСА_С_ОБРАБОТКОЙ_РЕЗУЛЬТАТА

	ПоместитьВоВременноеХранилище(ВтораяТаблица, АдресКопииТабличнойЧасти);

КонецПроцедуры
