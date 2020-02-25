///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2019, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область СлужебныйПрограммныйИнтерфейс

// Процедура обновляет данные регистра при полном обновлении вспомогательных данных.
//
// Параметры:
//  ЕстьИзменения - Булево - (возвращаемое значение) - если производилась запись,
//                  устанавливается Истина, иначе не изменяется.
//
Процедура ОбновитьДанныеРегистра(ЕстьИзменения = Неопределено) Экспорт
	
	Если Не УправлениеДоступомСлужебный.ОграничиватьДоступНаУровнеЗаписейУниверсально() Тогда
		Возврат;
	КонецЕсли;
	
	УправлениеДоступомСлужебный.ДействующиеПараметрыОграниченияДоступа(Неопределено,
		Неопределено, Истина, Ложь, Ложь, ЕстьИзменения);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

////////////////////////////////////////////////////////////////////////////////
// Обновление информационной базы.

// Обновляет версию текстов ограничений доступа.
//
// Параметры:
//  ЕстьИзменения - Булево - (возвращаемое значение) - если изменения найдены,
//                  устанавливается Истина, иначе не изменяется.
//
Процедура ОбновитьВерсиюТекстовОграниченияДоступа(ЕстьИзменения = Неопределено) Экспорт
	
	Если ОбщегоНазначения.РазделениеВключено()
	   И Не ОбщегоНазначения.ДоступноИспользованиеРазделенныхДанных() Тогда
		
		ВерсияИБ = ОбновлениеИнформационнойБазыСлужебный.ВерсияИБ("СтандартныеПодсистемы", Истина);
	Иначе
		ВерсияИБ = ОбновлениеИнформационнойБазыСлужебный.ВерсияИБ("СтандартныеПодсистемы");
	КонецЕсли;
	
	ВерсияТекстов = ВерсияТекстовОграниченияДоступа();
	
	НачатьТранзакцию();
	Попытка
		ЕстьТекущиеИзменения = Ложь;
		
		СтандартныеПодсистемыСервер.ОбновитьПараметрРаботыПрограммы(
			"СтандартныеПодсистемы.УправлениеДоступом.ВерсияТекстовОграниченияДоступа",
			ВерсияТекстов, ЕстьТекущиеИзменения);
		
		Если ОбщегоНазначенияКлиентСервер.СравнитьВерсии(ВерсияИБ, "3.0.3.92") < 0
		 Или ОбщегоНазначенияКлиентСервер.СравнитьВерсии(ВерсияИБ, "3.1.1.1") > 0
		   И ОбщегоНазначенияКлиентСервер.СравнитьВерсии(ВерсияИБ, "3.1.1.109") < 0
		 Или ОбщегоНазначенияКлиентСервер.СравнитьВерсии(ВерсияИБ, "3.1.2.1") > 0
		   И ОбщегоНазначенияКлиентСервер.СравнитьВерсии(ВерсияИБ, "3.1.2.150") < 0 Тогда
			
			ЕстьТекущиеИзменения = Истина;
		КонецЕсли;
		
		СтандартныеПодсистемыСервер.ДобавитьИзмененияПараметраРаботыПрограммы(
			"СтандартныеПодсистемы.УправлениеДоступом.ВерсияТекстовОграниченияДоступа",
			?(ЕстьТекущиеИзменения,
			  Новый ФиксированнаяСтруктура("ЕстьИзменения", Истина),
			  Новый ФиксированнаяСтруктура()) );
		
		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();
		ВызватьИсключение;
	КонецПопытки;
	
	Если ЕстьТекущиеИзменения Тогда
		ЕстьИзменения = Истина;
	КонецЕсли;
	
КонецПроцедуры

// Процедура обновляет вспомогательные данные регистра по результату изменения
// возможных прав по значениям доступа, сохраненных в параметрах ограничения доступа.
//
Процедура ЗапланироватьОбновлениеДоступаПоИзменениямКонфигурации() Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	
	ПоследниеИзменения = СтандартныеПодсистемыСервер.ИзмененияПараметраРаботыПрограммы(
		"СтандартныеПодсистемы.УправлениеДоступом.ВерсияТекстовОграниченияДоступа");
		
	Если ПоследниеИзменения = Неопределено Тогда
		ТребуетсяОбновление = Истина;
	Иначе
		ТребуетсяОбновление = Ложь;
		Для Каждого ЧастьИзменений Из ПоследниеИзменения Цикл
			
			Если ТипЗнч(ЧастьИзменений) = Тип("ФиксированнаяСтруктура")
			   И ЧастьИзменений.Свойство("ЕстьИзменения")
			   И ТипЗнч(ЧастьИзменений.ЕстьИзменения) = Тип("Булево") Тогда
				
				Если ЧастьИзменений.ЕстьИзменения Тогда
					ТребуетсяОбновление = Истина;
					Прервать;
				КонецЕсли;
			Иначе
				ТребуетсяОбновление = Истина;
				Прервать;
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;
	
	Если Не ТребуетсяОбновление Тогда
		Возврат;
	КонецЕсли;
	
	УправлениеДоступомСлужебный.ЗапланироватьОбновлениеПараметровОграниченияДоступа(
		"ЗапланироватьОбновлениеДоступаПоИзменениямКонфигурации");
	
	ВерсияИБ = ОбновлениеИнформационнойБазыСлужебный.ВерсияИБ("СтандартныеПодсистемы");
	
	Если ОбщегоНазначенияКлиентСервер.СравнитьВерсии(ВерсияИБ, "3.0.3.3") < 0
	 Или ОбщегоНазначенияКлиентСервер.СравнитьВерсии(ВерсияИБ, "3.1.1.1") > 0
	   И ОбщегоНазначенияКлиентСервер.СравнитьВерсии(ВерсияИБ, "3.1.1.109") < 0 Тогда
		
		ЗапланироватьОбновление(Ложь, Истина, "ПереходНаВерсиюБСП_3.0.3.3");
	КонецЕсли;
	
	Если ОбщегоНазначенияКлиентСервер.СравнитьВерсии(ВерсияИБ, "3.0.3.76") < 0
	 Или ОбщегоНазначенияКлиентСервер.СравнитьВерсии(ВерсияИБ, "3.1.2.1") > 0
	   И ОбщегоНазначенияКлиентСервер.СравнитьВерсии(ВерсияИБ, "3.1.2.134") < 0 Тогда
		
		ЗапланироватьОбновление(Истина, Ложь, "ПереходНаВерсиюБСП_3.0.3.76");
	КонецЕсли;
	
	Если ОбщегоНазначенияКлиентСервер.СравнитьВерсии(ВерсияИБ, "3.0.3.92") < 0
	 Или ОбщегоНазначенияКлиентСервер.СравнитьВерсии(ВерсияИБ, "3.1.2.1") > 0
	   И ОбщегоНазначенияКлиентСервер.СравнитьВерсии(ВерсияИБ, "3.1.2.150") < 0 Тогда
		
		ЗапланироватьОбновление(Ложь, Истина, "ПереходНаВерсиюБСП_3.0.3.92");
	КонецЕсли;
	
КонецПроцедуры

// Для процедуры ОбновитьДанныеРегистраПоИзменениямКонфигурации.
Процедура ЗапланироватьОбновление(КлючиДоступаКДанным, РазрешенныеКлючиДоступа, Описание)
	
	ОписаниеОграниченийДанных = УправлениеДоступомСлужебный.ОписаниеОграниченийДанных();
	ВнешниеПользователиВключены = Константы.ИспользоватьВнешнихПользователей.Получить();
	
	Списки = Новый Массив;
	СпискиДляВнешнихПользователей = Новый Массив;
	Для Каждого КлючИЗначение Из ОписаниеОграниченийДанных Цикл
		Списки.Добавить(КлючИЗначение.Ключ);
		Если ВнешниеПользователиВключены Тогда
			СпискиДляВнешнихПользователей.Добавить(КлючИЗначение.Ключ);
		КонецЕсли;
	КонецЦикла;
	
	ПараметрыПланирования = УправлениеДоступомСлужебный.ПараметрыПланированияОбновленияДоступа();
	
	ПараметрыПланирования.КлючиДоступаКДанным = КлючиДоступаКДанным;
	ПараметрыПланирования.РазрешенныеКлючиДоступа = РазрешенныеКлючиДоступа;
	ПараметрыПланирования.ДляВнешнихПользователей = Ложь;
	ПараметрыПланирования.ЭтоПродолжениеОбновления = Истина;
	ПараметрыПланирования.Описание = Описание;
	УправлениеДоступомСлужебный.ЗапланироватьОбновлениеДоступа(Списки, ПараметрыПланирования);
	
	ПараметрыПланирования.ДляПользователей = Ложь;
	ПараметрыПланирования.ДляВнешнихПользователей = Истина;
	ПараметрыПланирования.Описание = Описание;
	УправлениеДоступомСлужебный.ЗапланироватьОбновлениеДоступа(СпискиДляВнешнихПользователей, ПараметрыПланирования);
	
КонецПроцедуры

// Для процедуры ОбновитьВерсиюТекстовОграниченияДоступа.
Функция ВерсияТекстовОграниченияДоступа()
	
	ОписаниеОграничений = УправлениеДоступомСлужебный.ОписаниеОграниченийДанных();
	
	ВсеТексты = Новый СписокЗначений;
	Разделители = " 	" + Символы.ПС + Символы.ВК + Символы.НПП + Символы.ПФ;
	Для Каждого ОписаниеОграничения Из ОписаниеОграничений Цикл
		Ограничение = ОписаниеОграничения.Значение;
		Тексты = Новый Массив;
		Тексты.Добавить(ОписаниеОграничения.Ключ);
		ДобавитьСвойство(Тексты, Ограничение, Разделители, "Текст");
		ДобавитьСвойство(Тексты, Ограничение, Разделители, "ТекстДляВнешнихПользователей");
		ДобавитьСвойство(Тексты, Ограничение, Разделители, "ПоВладельцуБезЗаписиКлючейДоступа");
		ДобавитьСвойство(Тексты, Ограничение, Разделители, "ПоВладельцуБезЗаписиКлючейДоступаДляВнешнихПользователей");
		ДобавитьСвойство(Тексты, Ограничение, Разделители, "ТекстВМодулеМенеджера");
		ВсеТексты.Добавить(СтрСоединить(Тексты, Символы.ПС), ОписаниеОграничения.Ключ);
	КонецЦикла;
	ВсеТексты.СортироватьПоПредставлению();
	
	ПолныйТекст = СтрСоединить(ВсеТексты.ВыгрузитьЗначения(), Символы.ПС);
	
	Хеширование = Новый ХешированиеДанных(ХешФункция.SHA256);
	Хеширование.Добавить(ПолныйТекст);
	
	Возврат Base64Строка(Хеширование.ХешСумма);
	
КонецФункции

// Для функции ВерсияТекстовОграниченияДоступа.
Процедура ДобавитьСвойство(Тексты, Ограничение, Разделители, ИмяСвойства)
	
	Значение = Ограничение[ИмяСвойства];
	Если ТипЗнч(Значение) = Тип("Строка") Тогда
		Текст = СтрСоединить(СтрРазделить(НРег(Значение), Разделители, Ложь), " ");
	Иначе
		Текст = Строка(Значение);
	КонецЕсли;
	
	Тексты.Добавить("	" + ИмяСвойства + ": " + Текст);
	
КонецПроцедуры

Процедура ЗарегистрироватьДанныеКОбработкеДляПереходаНаНовуюВерсию3(Параметры) Экспорт
	
	// Регистрация данных не требуется.
	
КонецПроцедуры

Процедура ОбработатьДанныеДляПереходаНаНовуюВерсию3(Параметры) Экспорт
	
	ВключитьОграничениеДоступаНаУровнеЗаписейУниверсально();
	
	Параметры.ОбработкаЗавершена = Истина;
	
КонецПроцедуры

Процедура ВключитьОграничениеДоступаНаУровнеЗаписейУниверсально() Экспорт
	
	Константы.ОграничиватьДоступНаУровнеЗаписейУниверсально.Установить(Истина);
	
КонецПроцедуры

#КонецОбласти

#КонецЕсли
