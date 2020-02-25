///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2019, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Заголовок = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(НСтр("ru = 'Быстрый доступ к команде ""%1""'"), Параметры.ПредставлениеКоманды);
	
	ЗаполнитьТаблицы();
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовТаблицыФормыВсеПользователи

&НаКлиенте
Процедура ВсеПользователиПеретаскивание(Элемент, ПараметрыПеретаскивания, СтандартнаяОбработка, Строка, Поле)
	
	Если ТипЗнч(ПараметрыПеретаскивания.Значение[0]) = Тип("Число") Тогда
		Возврат;
	КонецЕсли;
	
	ПеренестиПользователей(ВсеПользователи, ПользователиКороткогоСписка, ПараметрыПеретаскивания.Значение);
	
КонецПроцедуры

&НаКлиенте
Процедура ВсеПользователиПроверкаПеретаскивания(Элемент, ПараметрыПеретаскивания, СтандартнаяОбработка, Строка, Поле)
	
	СтандартнаяОбработка = Ложь;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовТаблицыФормыПользователиКороткогоСписка

&НаКлиенте
Процедура ПользователиКороткогоСпискаПеретаскивание(Элемент, ПараметрыПеретаскивания, СтандартнаяОбработка, Строка, Поле)
	
	Если ТипЗнч(ПараметрыПеретаскивания.Значение[0]) = Тип("Число") Тогда
		Возврат;
	КонецЕсли;
	
	ПеренестиПользователей(ПользователиКороткогоСписка, ВсеПользователи, ПараметрыПеретаскивания.Значение);
	
КонецПроцедуры

&НаКлиенте
Процедура ПользователиКороткогоСпискаПроверкаПеретаскивания(Элемент, ПараметрыПеретаскивания, СтандартнаяОбработка, Строка, Поле)
	
	СтандартнаяОбработка = Ложь;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура УбратьДоступККомандеУВсехПользователей(Команда)
	
	МассивПеретаскиваемыхЭлементов = Новый Массив;
	
	Для Каждого ОписаниеСтроки Из ПользователиКороткогоСписка Цикл
		МассивПеретаскиваемыхЭлементов.Добавить(ОписаниеСтроки);
	КонецЦикла;
	
	ПеренестиПользователей(ВсеПользователи, ПользователиКороткогоСписка, МассивПеретаскиваемыхЭлементов);
	
КонецПроцедуры

&НаКлиенте
Процедура УбратьДоступККомандеУВыделенныхПользователей(Команда)
	
	МассивПеретаскиваемыхЭлементов = Новый Массив;
	
	Для Каждого ВыделеннаяСтрока Из Элементы.ПользователиКороткогоСписка.ВыделенныеСтроки Цикл
		МассивПеретаскиваемыхЭлементов.Добавить(Элементы.ПользователиКороткогоСписка.ДанныеСтроки(ВыделеннаяСтрока));
	КонецЦикла;
	
	ПеренестиПользователей(ВсеПользователи, ПользователиКороткогоСписка, МассивПеретаскиваемыхЭлементов);
	
КонецПроцедуры

&НаКлиенте
Процедура УстановитьДоступДляВсехПользователей(Команда)
	
	МассивПеретаскиваемыхЭлементов = Новый Массив;
	
	Для Каждого ОписаниеСтроки Из ВсеПользователи Цикл
		МассивПеретаскиваемыхЭлементов.Добавить(ОписаниеСтроки);
	КонецЦикла;
	
	ПеренестиПользователей(ПользователиКороткогоСписка, ВсеПользователи, МассивПеретаскиваемыхЭлементов);
	
КонецПроцедуры

&НаКлиенте
Процедура УстановитьКомандуДляВыделенныхПользователей(Команда)
	
	МассивПеретаскиваемыхЭлементов = Новый Массив;
	
	Для Каждого ВыделеннаяСтрока Из Элементы.ВсеПользователи.ВыделенныеСтроки Цикл
		МассивПеретаскиваемыхЭлементов.Добавить(Элементы.ВсеПользователи.ДанныеСтроки(ВыделеннаяСтрока));
	КонецЦикла;
	
	ПеренестиПользователей(ПользователиКороткогоСписка, ВсеПользователи, МассивПеретаскиваемыхЭлементов);
	
КонецПроцедуры

&НаКлиенте
Процедура ОК(Команда)
	
	РезультатВыбора = Новый СписокЗначений;
	
	Для Каждого ЭлементКоллекции Из ПользователиКороткогоСписка Цикл
		РезультатВыбора.Добавить(ЭлементКоллекции.Пользователь);
	КонецЦикла;
	
	ОповеститьОВыборе(РезультатВыбора);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура ЗаполнитьТаблицы()
	СписокВыбранных = Параметры.ПользователиСБыстрымДоступом;
	Запрос = Новый Запрос("ВЫБРАТЬ Ссылка ИЗ Справочник.Пользователи ГДЕ НЕ ПометкаУдаления И НЕ Недействителен И НЕ Служебный");
	Выборка = Запрос.Выполнить().Выбрать();
	Пока Выборка.Следующий() Цикл
		Если СписокВыбранных.НайтиПоЗначению(Выборка.Ссылка) = Неопределено Тогда
			ВсеПользователи.Добавить().Пользователь = Выборка.Ссылка;
		Иначе
			ПользователиКороткогоСписка.Добавить().Пользователь = Выборка.Ссылка;
		КонецЕсли;
	КонецЦикла;
	ВсеПользователи.Сортировать("Пользователь Возр");
	ПользователиКороткогоСписка.Сортировать("Пользователь Возр");
КонецПроцедуры

&НаКлиенте
Процедура ПеренестиПользователей(Приемник, Источник, МассивПеретаскиваемыхЭлементов)
	
	Для Каждого ПеретаскиваемыйЭлемент Из МассивПеретаскиваемыхЭлементов Цикл
		НовыйПользователь = Приемник.Добавить();
		НовыйПользователь.Пользователь = ПеретаскиваемыйЭлемент.Пользователь;
		Источник.Удалить(ПеретаскиваемыйЭлемент);
	КонецЦикла;
	
	Приемник.Сортировать("Пользователь Возр");
	
КонецПроцедуры

#КонецОбласти
