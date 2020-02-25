///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2019, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда
	
#Область СлужебныеПроцедурыИФункции

#Область ОбработчикиОбновления

Процедура ЗарегистрироватьДанныеКОбработкеДляПереходаНаНовуюВерсию(Параметры) Экспорт
	
	Если Не ОбщегоНазначения.ДоступноИспользованиеРазделенныхДанных() Тогда
		Возврат;
	КонецЕсли;
	
	ДополнительныеПараметры = ОбновлениеИнформационнойБазы.ДополнительныеПараметрыОтметкиОбработки();
	ДополнительныеПараметры.ЭтоНезависимыйРегистрСведений = Истина;
	ДополнительныеПараметры.ПолноеИмяРегистра             = "РегистрСведений.УдалитьРезультатыОбменаДанными";
	
	Запрос = Новый Запрос(
	"ВЫБРАТЬ
	|	УдалитьРезультатыОбменаДанными.ПроблемныйОбъект КАК ПроблемныйОбъект,
	|	УдалитьРезультатыОбменаДанными.ТипПроблемы КАК ТипПроблемы
	|ИЗ
	|	РегистрСведений.УдалитьРезультатыОбменаДанными КАК УдалитьРезультатыОбменаДанными");
	
	Результат = Запрос.Выполнить().Выгрузить();
	
	ОбновлениеИнформационнойБазы.ОтметитьКОбработке(Параметры, Результат, ДополнительныеПараметры);
	
КонецПроцедуры

Процедура ОбработатьДанныеДляПереходаНаНовуюВерсию(Параметры) Экспорт
	
	Если Не ОбщегоНазначения.ДоступноИспользованиеРазделенныхДанных() Тогда
		Возврат;
	КонецЕсли;
	
	ОбработкаЗавершена = Истина;
	
	МетаданныеРегистра    = Метаданные.РегистрыСведений.УдалитьРезультатыОбменаДанными;
	ПолноеИмяРегистра     = МетаданныеРегистра.ПолноеИмя();
	ПредставлениеРегистра = МетаданныеРегистра.Представление();
	
	ДополнительныеПараметрыВыборкиДанныхДляОбработки = ОбновлениеИнформационнойБазы.ДополнительныеПараметрыВыборкиДанныхДляОбработки();
	
	Выборка = ОбновлениеИнформационнойБазы.ВыбратьИзмеренияНезависимогоРегистраСведенийДляОбработки(
		Параметры.Очередь, ПолноеИмяРегистра, ДополнительныеПараметрыВыборкиДанныхДляОбработки);
	
	Обработано = 0;
	Проблемных = 0;
	
	Пока Выборка.Следующий() Цикл
		
		Попытка
			
			ПеренестиЗаписиРегистра(Выборка);
			Обработано = Обработано + 1;
			
		Исключение
			
			Проблемных = Проблемных + 1;
			
			ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Не удалось обработать набор записей регистра ""%1"" по причине:
				|%2'"), ПредставлениеРегистра, ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
				
			ЗаписьЖурналаРегистрации(ОбновлениеИнформационнойБазы.СобытиеЖурналаРегистрации(), УровеньЖурналаРегистрации.Предупреждение,
				МетаданныеРегистра, , ТекстСообщения);
			
		КонецПопытки;
		
	КонецЦикла;
	
	Если Не ОбновлениеИнформационнойБазы.ОбработкаДанныхЗавершена(Параметры.Очередь, ПолноеИмяРегистра) Тогда
		ОбработкаЗавершена = Ложь;
	КонецЕсли;
	
	Если Обработано = 0 И Проблемных <> 0 Тогда
		ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Процедуре РегистрыСведений.УдалитьРезультатыОбменаДанными.ОбработатьДанныеДляПереходаНаНовуюВерсию не удалось обработать некоторые записи. Пропущены: %1'"), 
			Проблемных);
		ВызватьИсключение ТекстСообщения;
	Иначе
		ЗаписьЖурналаРегистрации(ОбновлениеИнформационнойБазы.СобытиеЖурналаРегистрации(), УровеньЖурналаРегистрации.Информация,
			, ,
			СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Процедура РегистрыСведений.УдалитьРезультатыОбменаДанными.ОбработатьДанныеДляПереходаНаНовуюВерсию обработала очередную порцию записей: %1'"),
			Обработано));
	КонецЕсли;
	
	Параметры.ОбработкаЗавершена = ОбработкаЗавершена;
	
КонецПроцедуры

Процедура ПеренестиЗаписиРегистра(ЗаписьРегистра) 
	
	Если Не ЗначениеЗаполнено(ЗаписьРегистра.ПроблемныйОбъект) Тогда
		НаборЗаписейСтарый = СоздатьНаборЗаписей();
		НаборЗаписейСтарый.Отбор.ПроблемныйОбъект.Установить(ЗаписьРегистра.ПроблемныйОбъект);
		НаборЗаписейСтарый.Отбор.ТипПроблемы.Установить(ЗаписьРегистра.ТипПроблемы);
		
		ОбновлениеИнформационнойБазы.ЗаписатьНаборЗаписей(НаборЗаписейСтарый);
		Возврат;
	КонецЕсли;
	
	НачатьТранзакцию();
	Попытка
		
		ИдентификаторОбъектаМетаданных = ОбщегоНазначения.ИдентификаторОбъектаМетаданных(ЗаписьРегистра.ПроблемныйОбъект.Метаданные());
		
		Блокировка = Новый БлокировкаДанных;
		
		ЭлементБлокировки = Блокировка.Добавить("РегистрСведений.УдалитьРезультатыОбменаДанными");
		ЭлементБлокировки.УстановитьЗначение("ПроблемныйОбъект", ЗаписьРегистра.ПроблемныйОбъект);
		ЭлементБлокировки.УстановитьЗначение("ТипПроблемы",      ЗаписьРегистра.ТипПроблемы);		
		
		ЭлементБлокировки = Блокировка.Добавить("РегистрСведений.РезультатыОбменаДанными");
		ЭлементБлокировки.УстановитьЗначение("ТипПроблемы",      ЗаписьРегистра.ТипПроблемы);
		ЭлементБлокировки.УстановитьЗначение("ОбъектМетаданных", ИдентификаторОбъектаМетаданных);
		ЭлементБлокировки.УстановитьЗначение("ПроблемныйОбъект", ЗаписьРегистра.ПроблемныйОбъект);
		
		Блокировка.Заблокировать();
		
		НаборЗаписейСтарый = СоздатьНаборЗаписей();
		НаборЗаписейСтарый.Отбор.ПроблемныйОбъект.Установить(ЗаписьРегистра.ПроблемныйОбъект);
		НаборЗаписейСтарый.Отбор.ТипПроблемы.Установить(ЗаписьРегистра.ТипПроблемы);
		
		НаборЗаписейСтарый.Прочитать();
		
		Если НаборЗаписейСтарый.Количество() = 0 Тогда
			ОбновлениеИнформационнойБазы.ОтметитьВыполнениеОбработки(НаборЗаписейСтарый);
		Иначе
			
			НаборЗаписейНовый = РегистрыСведений.РезультатыОбменаДанными.СоздатьНаборЗаписей();
			НаборЗаписейНовый.Отбор.ТипПроблемы.Установить(ЗаписьРегистра.ТипПроблемы);		
			НаборЗаписейНовый.Отбор.ОбъектМетаданных.Установить(ИдентификаторОбъектаМетаданных);
			НаборЗаписейНовый.Отбор.ПроблемныйОбъект.Установить(ЗаписьРегистра.ПроблемныйОбъект);
			
			ЗаписьНовый = НаборЗаписейНовый.Добавить();
			ЗаполнитьЗначенияСвойств(ЗаписьНовый, НаборЗаписейСтарый[0]);
			
			ЗаписьНовый.ОбъектМетаданных = ИдентификаторОбъектаМетаданных;
			
			ОбновлениеИнформационнойБазы.ЗаписатьНаборЗаписей(НаборЗаписейНовый);
			
			НаборЗаписейСтарый.Очистить();
			ОбновлениеИнформационнойБазы.ЗаписатьНаборЗаписей(НаборЗаписейСтарый);
			
		КонецЕсли;
		
		ЗафиксироватьТранзакцию();
		
	Исключение
		
		ОтменитьТранзакцию();
		ВызватьИсключение;
		
	КонецПопытки	
	
КонецПроцедуры

#КонецОбласти

#КонецОбласти
	
#КонецЕсли