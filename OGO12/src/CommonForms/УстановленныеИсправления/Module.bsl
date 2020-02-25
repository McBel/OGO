///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2019, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОписаниеПеременных

&НаКлиенте
Перем ТекущийКонтекст;

#КонецОбласти

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Параметры.Свойство("АвтоТест") Тогда
		Возврат;
	КонецЕсли;
	
	Если СтандартныеПодсистемыСервер.ЭтоБазоваяВерсияКонфигурации() Тогда
		ВызватьИсключение НСтр("ru = 'Текущий режим работы не поддерживается.'");
	КонецЕсли;
	
	Фильтр = Параметры.Исправления;
	
	Если ОбщегоНазначения.ЭтоВебКлиент()
		Или ОбщегоНазначения.РазделениеВключено()
		Или ОбщегоНазначения.ЭтоПодчиненныйУзелРИБ()
		Или Не ОбщегоНазначения.ЭтоWindowsКлиент() Тогда
		Элементы.ФормаУстановитьИсправление.Видимость = Ложь;
		Элементы.ФормаУдалитьИсправление.Видимость    = Ложь;
		Элементы.ГруппаИнформация.Видимость           = Ложь;
	КонецЕсли;
	
	ОбновитьСписокИсправлений();
	
	Элементы.УстановленныеИсправленияПрименимоДля.Видимость = Ложь;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ДекорацияЖурналРегистрацииНажатие(Элемент)
	МассивСобытий = Новый Массив;
	МассивСобытий.Добавить(НСтр("ru = 'Исправления. Установка'"));
	МассивСобытий.Добавить(НСтр("ru = 'Исправления. Изменение'"));
	МассивСобытий.Добавить(НСтр("ru = 'Исправления. Удаление'"));
	Отбор = Новый Структура("СобытиеЖурналаРегистрации", МассивСобытий);
	ЖурналРегистрацииКлиент.ОткрытьЖурналРегистрации(Отбор);
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовТаблицыФормыУстановленныеИсправления

&НаКлиенте
Процедура УстановленныеИсправленияПередУдалением(Элемент, Отказ)
	Отказ = Истина;
	УдалитьРасширения(Элемент.ВыделенныеСтроки);
КонецПроцедуры

&НаКлиенте
Процедура УстановленныеИсправленияПередНачаломДобавления(Элемент, Отказ, Копирование, Родитель, Группа, Параметр)
	Отказ = Истина;
	Оповещение = Новый ОписаниеОповещения("ПослеУстановкиИсправлений", ЭтотОбъект);
	ОткрытьФорму("Обработка.УстановкаОбновлений.Форма.Форма",,,,,, Оповещение);
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура ОбновитьСписокИсправлений()
	
	УстановленныеИсправления.Очистить();
	Элементы.УстановленныеИсправленияПутьКФайлу.Видимость = Ложь;
	
	УстановитьПривилегированныйРежим(Истина);
	Расширения = РасширенияКонфигурации.Получить();
	УстановитьПривилегированныйРежим(Ложь);
	
	Для Каждого Расширение Из Расширения Цикл
		
		Если Не ОбновлениеКонфигурации.ЭтоИсправление(Расширение) Тогда
			Продолжить;
		КонецЕсли;
		
		Если Фильтр <> Неопределено И Фильтр.НайтиПоЗначению(Расширение.Имя) = Неопределено Тогда
			Продолжить;
		КонецЕсли;
		
		СвойстваИсправления = ОбновлениеКонфигурации.СвойстваИсправления(Расширение.Имя);
		
		НоваяСтрока = УстановленныеИсправления.Добавить();
		НоваяСтрока.Имя = Расширение.Имя;
		НоваяСтрока.КонтрольнаяСумма = Base64Строка(Расширение.ХешСумма);
		НоваяСтрока.ИдентификаторРасширения = Расширение.УникальныйИдентификатор;
		НоваяСтрока.Версия = Расширение.Версия;
		Если СвойстваИсправления <> Неопределено Тогда
			НоваяСтрока.Статус = 0;
			НоваяСтрока.Описание = СвойстваИсправления.Description;
			НоваяСтрока.ПрименимоДля = ИсправлениеПрименимоДля(СвойстваИсправления);
		Иначе
			НоваяСтрока.Статус = 1;
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры

&НаСервере
Функция ИсправлениеПрименимоДля(СвойстваИсправления)
	
	ПрименимоДля = Новый Массив;
	Для Каждого Строка Из СвойстваИсправления.AppliedFor Цикл
		ПрименимоДля.Добавить(Строка.ConfigurationName);
	КонецЦикла;
	
	Возврат СтрСоединить(ПрименимоДля, Символы.ПС);
	
КонецФункции

&НаКлиенте
Процедура УдалитьРасширения(ВыделенныеСтроки)
	
	Если ВыделенныеСтроки.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;
	
	Контекст = Новый Структура;
	Контекст.Вставить("ВыделенныеСтроки", ВыделенныеСтроки);
	
	Оповещение = Новый ОписаниеОповещения("УдалитьРасширениеПослеПодтверждения", ЭтотОбъект, Контекст);
	Если ВыделенныеСтроки.Количество() > 1 Тогда
		ТекстВопроса = НСтр("ru = 'Удалить выделенные исправления?'", "ru");
	Иначе
		ТекстВопроса = НСтр("ru = 'Удалить исправление?'", "ru");
	КонецЕсли;
	
	ПоказатьВопрос(Оповещение, ТекстВопроса, РежимДиалогаВопрос.ДаНет);
	
КонецПроцедуры

&НаКлиенте
Процедура УдалитьРасширениеПослеПодтверждения(Результат, Контекст) Экспорт
	
	Если Результат = КодВозвратаДиалога.Да Тогда
		
		Обработчик = Новый ОписаниеОповещения("УдалитьРасширениеПродолжение", ЭтотОбъект, Контекст);
		
		Если ОбщегоНазначенияКлиент.ПодсистемаСуществует("СтандартныеПодсистемы.ПрофилиБезопасности") Тогда
			Запросы = ЗапросНаОтменуРазрешенийИспользованияВнешнегоМодуля(Контекст.ВыделенныеСтроки);
			МодульРаботаВБезопасномРежимеКлиент = ОбщегоНазначенияКлиент.ОбщийМодуль("РаботаВБезопасномРежимеКлиент");
			МодульРаботаВБезопасномРежимеКлиент.ПрименитьЗапросыНаИспользованиеВнешнихРесурсов(Запросы, ЭтотОбъект, Обработчик);
		Иначе
			ВыполнитьОбработкуОповещения(Обработчик, КодВозвратаДиалога.ОК);
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура УдалитьРасширениеПродолжение(Результат, Контекст) Экспорт
	
	Если Результат = КодВозвратаДиалога.ОК Тогда
		ТекущийКонтекст = Контекст;
		ПодключитьОбработчикОжидания("УдалитьРасширениеЗавершение", 0.1, Истина);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура УдалитьРасширениеЗавершение()
	
	Контекст = ТекущийКонтекст;
	
	Попытка
		УдалитьРасширенияНаСервере(Контекст.ВыделенныеСтроки);
	Исключение
		ИнформацияОбОшибке = ИнформацияОбОшибке();
		ПоказатьПредупреждение(, КраткоеПредставлениеОшибки(ИнформацияОбОшибке));
		Возврат;
	КонецПопытки;
	
КонецПроцедуры

&НаСервере
Процедура УдалитьРасширенияНаСервере(ВыделенныеСтроки)
	
	УдаляемыеРасширения = Новый Массив;
	
	ТекстОшибки = "";
	Попытка
		УдаляемоеРасширение = "";
		Для Каждого ЭлементСписка Из УстановленныеИсправления Цикл
			Если ВыделенныеСтроки.Найти(ЭлементСписка.ПолучитьИдентификатор()) = Неопределено Тогда
				Продолжить;
			КонецЕсли;
			Расширение = НайтиРасширение(ЭлементСписка.ИдентификаторРасширения);
			Если Расширение <> Неопределено Тогда
				ОписаниеРасширения = Новый Структура;
				ОписаниеРасширения.Вставить("Удалено", Ложь);
				ОписаниеРасширения.Вставить("Расширение", Расширение);
				ОписаниеРасширения.Вставить("ДанныеРасширения", Расширение.ПолучитьДанные());
				УдаляемыеРасширения.Добавить(ОписаниеРасширения);
			КонецЕсли;
		КонецЦикла;
		Индекс = УдаляемыеРасширения.Количество() - 1;
		Пока Индекс >= 0 Цикл
			ОписаниеРасширения = УдаляемыеРасширения[Индекс];
			ОтключитьПредупрежденияБезопасности(ОписаниеРасширения.Расширение);
			УдаляемоеРасширение = ОписаниеРасширения.Расширение.Синоним;
			ОписаниеРасширения.Расширение.Удалить();
			УдаляемоеРасширение = "";
			ОписаниеРасширения.Удалено = Истина;
			Индекс = Индекс - 1;
		КонецЦикла;
		
		Если ОбщегоНазначения.ДоступноИспользованиеРазделенныхДанных()
		   И РасширенияКонфигурации.Получить().Количество() = 0 Тогда
			
			Справочники.ВерсииРасширений.ПриУдаленииВсехРасширений();
		КонецЕсли;
	Исключение
		ИнформацияОбОшибке = ИнформацияОбОшибке();
		ТекстОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Не удалось удалить расширение ""%1"" по причине:
			           |
			           |%2'"),
			УдаляемоеРасширение,
			КраткоеПредставлениеОшибки(ИнформацияОбОшибке));
	КонецПопытки;
	
	Если Не ЗначениеЗаполнено(ТекстОшибки) Тогда
		Попытка
			РегистрыСведений.ПараметрыРаботыВерсийРасширений.ОбновитьПараметрыРаботыРасширений();
		Исключение
			ИнформацияОбОшибке = ИнформацияОбОшибке();
			ТекстОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'После удаления, при подготовке оставшихся расширений к работе, произошла ошибка:
				           |
				           |%1'"), КраткоеПредставлениеОшибки(ИнформацияОбОшибке));
		КонецПопытки;
	КонецЕсли;
	
	Если ЗначениеЗаполнено(ТекстОшибки) Тогда
		ИнформацияОбОшибкеВосстановления = Неопределено;
		ВосстановлениеВыполнялось = Ложь;
		Попытка
			Для Каждого ОписаниеРасширения Из УдаляемыеРасширения Цикл
				Если Не ОписаниеРасширения.Удалено Тогда
					Продолжить;
				КонецЕсли;
				ОписаниеРасширения.Расширение.Записать(ОписаниеРасширения.ДанныеРасширения);
				ВосстановлениеВыполнялось = Истина;
			КонецЦикла;
		Исключение
			ИнформацияОбОшибкеВосстановления = ИнформацияОбОшибке();
			ТекстОшибки = ТекстОшибки + Символы.ПС + Символы.ПС
				+ СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
					НСтр("ru = 'При попытке восстановить удаленные расширения произошла еще одна ошибка:
					           |%1'"), КраткоеПредставлениеОшибки(ИнформацияОбОшибкеВосстановления));
		КонецПопытки;
		Если ВосстановлениеВыполнялось
		   И ИнформацияОбОшибкеВосстановления = Неопределено Тогда
			
			ТекстОшибки = ТекстОшибки + Символы.ПС + Символы.ПС
				+ НСтр("ru = 'Удаленные расширения были восстановлены.'");
		КонецЕсли;
	КонецЕсли;
	
	Если ЗначениеЗаполнено(ТекстОшибки) Тогда
		ВызватьИсключение ТекстОшибки;
	КонецЕсли;
	
	ОбновитьСписокИсправлений();
	
КонецПроцедуры

&НаСервере
Функция НайтиРасширение(ИдентификаторРасширения)
	
	Отбор = Новый Структура;
	Отбор.Вставить("УникальныйИдентификатор", Новый УникальныйИдентификатор(ИдентификаторРасширения));
	УстановитьПривилегированныйРежим(Истина);
	Расширения = РасширенияКонфигурации.Получить(Отбор);
	УстановитьПривилегированныйРежим(Ложь);
	
	Расширение = Неопределено;
	
	Если Расширения.Количество() = 1 Тогда
		Расширение = Расширения[0];
	КонецЕсли;
	
	Возврат Расширение;
	
КонецФункции

&НаСервере
Процедура ОтключитьПредупрежденияБезопасности(Расширение)
	
	Расширение.ЗащитаОтОпасныхДействий = ОбщегоНазначения.ОписаниеЗащитыБезПредупреждений();
	
КонецПроцедуры

&НаСервере
Функция ЗапросНаОтменуРазрешенийИспользованияВнешнегоМодуля(ВыделенныеСтроки)
	
	Разрешения = Новый Массив;
	МодульРаботаВБезопасномРежиме = ОбщегоНазначения.ОбщийМодуль("РаботаВБезопасномРежиме");
	
	Для Каждого ИдентификаторСтроки Из ВыделенныеСтроки Цикл
		ТекущееРасширение = УстановленныеИсправления.НайтиПоИдентификатору(ИдентификаторСтроки);
		Разрешения.Добавить(МодульРаботаВБезопасномРежиме.РазрешениеНаИспользованиеВнешнегоМодуля(
			ТекущееРасширение.Имя, ТекущееРасширение.КонтрольнаяСумма));
	КонецЦикла;
	
	Запросы = Новый Массив;
	Запросы.Добавить(МодульРаботаВБезопасномРежиме.ЗапросНаОтменуРазрешенийИспользованияВнешнихРесурсов(
		ОбщегоНазначения.ИдентификаторОбъектаМетаданных("РегистрСведений.ПараметрыРаботыВерсийРасширений"),
		Разрешения));
		
	Возврат Запросы;
	
КонецФункции

&НаКлиенте
Процедура ПослеУстановкиИсправлений(Результат, ДополнительныеПараметры) Экспорт
	ОбновитьСписокИсправлений();
КонецПроцедуры

#КонецОбласти