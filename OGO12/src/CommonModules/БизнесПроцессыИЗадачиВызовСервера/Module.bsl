///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2019, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ПрограммныйИнтерфейс

// Получить структуру с описанием формы выполнения задачи.
//
// Параметры:
//  ЗадачаСсылка  - ЗадачаСсылка.ЗадачаИсполнителя - задача.
//
// Возвращаемое значение:
//   Структура   - структуру с описанием формы выполнения задачи.
//
Функция ФормаВыполненияЗадачи(Знач ЗадачаСсылка) Экспорт
	
	Если ТипЗнч(ЗадачаСсылка) <> Тип("ЗадачаСсылка.ЗадачаИсполнителя") Тогда
		
		ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(НСтр("ru = 'Неправильный тип параметра ЗадачаСсылка (передан: %1; ожидается: %2)'"),
			ТипЗнч(ЗадачаСсылка), "ЗадачаСсылка.ЗадачаИсполнителя");
		ВызватьИсключение ТекстСообщения;
		
	КонецЕсли;
	
	Реквизиты = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(ЗадачаСсылка, "БизнесПроцесс,ТочкаМаршрута");
	Если Реквизиты.БизнесПроцесс = Неопределено ИЛИ Реквизиты.БизнесПроцесс.Пустая() Тогда
		Возврат Новый Структура();
	КонецЕсли;
	
	ТипБизнесПроцесса = Реквизиты.БизнесПроцесс.Метаданные();
	ПараметрыФормы = БизнесПроцессы[ТипБизнесПроцесса.Имя].ФормаВыполненияЗадачи(ЗадачаСсылка,
		Реквизиты.ТочкаМаршрута);
	БизнесПроцессыИЗадачиПереопределяемый.ПриПолученииФормыВыполненияЗадачи(
		ТипБизнесПроцесса.Имя, ЗадачаСсылка, Реквизиты.ТочкаМаршрута, ПараметрыФормы);
	
	Возврат ПараметрыФормы;
	
КонецФункции

// Проверяет, находится ли в ячейке отчета ссылка на задачу и в параметре.
//  ЗначениеРасшифровки возвращает значение расшифровки.
//
// Параметры:
//  Расшифровка             - Строка - имя ячейки.
//  ДанныеРасшифровкиОтчета - Строка - Адрес во временном хранилище.
//  ЗначениеРасшифровки     - ЗадачаСсылка.ЗадачаИсполнителя, Произвольный - Значение расшифровки из ячейки.
// 
// Возвращаемое значение:
//  Булево -Если Истина, то это задача исполнителю.
//
Функция ЭтоЗадачаИсполнителю(Знач Расшифровка, Знач ДанныеРасшифровкиОтчета, ЗначениеРасшифровки) Экспорт
	
	ДанныеРасшифровкиОбъект = ПолучитьИзВременногоХранилища(ДанныеРасшифровкиОтчета);
	ЗначениеРасшифровки = ДанныеРасшифровкиОбъект.Элементы[Расшифровка].ПолучитьПоля()[0].Значение;
	Возврат ТипЗнч(ЗначениеРасшифровки) = Тип("ЗадачаСсылка.ЗадачаИсполнителя");
	
КонецФункции

// Выполнить задачу ЗадачаСсылка, при необходимости выполнив обработчик.
//  ОбработкаВыполненияПоУмолчанию модуля менеджера бизнес-процесса,
//  к которому относится задача ЗадачаСсылка.
//
// Параметры:
//  ЗадачаСсылка        - ЗадачаСсылка - ссылка на задачу.
//  ДействиеПоУмолчанию - Булево        -Признак необходимости вызова процедуры 
//                                       ОбработкаВыполненияПоУмолчанию у бизнес-процесса задачи.
//
Процедура ВыполнитьЗадачу(ЗадачаСсылка, ДействиеПоУмолчанию = Ложь) Экспорт

	НачатьТранзакцию();
	Попытка
		БизнесПроцессыИЗадачиСервер.ЗаблокироватьЗадачи(ЗадачаСсылка);
		
		ЗадачаОбъект = ЗадачаСсылка.ПолучитьОбъект();
		Если ЗадачаОбъект.Выполнена Тогда
			ВызватьИсключение НСтр("ru = 'Задача уже была выполнена ранее.'");
		КонецЕсли;
		
		Если ДействиеПоУмолчанию И ЗадачаОбъект.БизнесПроцесс <> Неопределено 
			И НЕ ЗадачаОбъект.БизнесПроцесс.Пустая() Тогда
			ТипБизнесПроцесса = ЗадачаОбъект.БизнесПроцесс.Метаданные();
			БизнесПроцессы[ТипБизнесПроцесса.Имя].ОбработкаВыполненияПоУмолчанию(ЗадачаСсылка,
				ЗадачаОбъект.БизнесПроцесс, ЗадачаОбъект.ТочкаМаршрута);
		КонецЕсли;
			
		ЗадачаОбъект.Выполнена = Ложь;
		ЗадачаОбъект.ВыполнитьЗадачу();
		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();
		ВызватьИсключение;
	КонецПопытки;

КонецПроцедуры

// Перенаправить задачи МассивЗадач новому исполнителю, указанному в структуре.
// ИнфоОПеренаправлении. 
//
// Параметры:
//  МассивЗадач          - Массив    - массив задач для перенаправления.
//  ИнфоОПеренаправлении - Структура - содержит новые значения реквизитов адресации задачи.
//  ТолькоПроверка       - Булево    - если Истина, то функция не будет выполнять
//                                     физического перенаправления задач, а только 
//                                     проверит возможность перенаправления.
//  МассивПеренаправленныхЗадач - Массив - массив перенаправленных задач.
//                                         Может отличаться по составу элементов от 
//                                         массива МассивЗадач, если какие-то задачи
//                                         не удалось перенаправить.
//
// Возвращаемое значение:
//   Булево   - Истина, если перенаправление выполнено успешно.
//
Функция ПеренаправитьЗадачи(Знач МассивЗадач, Знач ИнфоОПеренаправлении, Знач ТолькоПроверка = Ложь,
	МассивПеренаправленныхЗадач = Неопределено) Экспорт
	
	Результат = Истина;
	
	СведенияОЗадачах = ОбщегоНазначения.ЗначенияРеквизитовОбъектов(МассивЗадач, "БизнесПроцесс,Выполнена");
	НачатьТранзакцию();
	Попытка
		Для Каждого Задача Из СведенияОЗадачах Цикл
			
			Если Задача.Значение.Выполнена Тогда
				Результат = Ложь;
				Если ТолькоПроверка Тогда
					ОтменитьТранзакцию();
					Возврат Результат;
				КонецЕсли;
			КонецЕсли;	
			
			БизнесПроцессыИЗадачиСервер.ЗаблокироватьЗадачи(Задача.Ключ);
			Если ЗначениеЗаполнено(Задача.Значение.БизнесПроцесс) И Не Задача.Значение.БизнесПроцесс.Пустая() Тогда
				БизнесПроцессыИЗадачиСервер.ЗаблокироватьБизнесПроцессы(Задача.Значение.БизнесПроцесс);
			КонецЕсли;
		КонецЦикла;
						
		Если ТолькоПроверка Тогда
			Для Каждого Задача Из СведенияОЗадачах Цикл
				ЗадачаОбъект = Задача.Ключ.ПолучитьОбъект();
				ЗадачаОбъект.Выполнена = Ложь;
				ЗадачаОбъект.ДополнительныеСвойства.Вставить("Перенаправление", Истина);
				ЗадачаОбъект.ВыполнитьЗадачу();
			КонецЦикла;	
			ОтменитьТранзакцию();
			Возврат Результат;
		КонецЕсли;	
		
		Для Каждого Задача Из СведенияОЗадачах Цикл
			
			Если НЕ ЗначениеЗаполнено(МассивПеренаправленныхЗадач) Тогда
				МассивПеренаправленныхЗадач = Новый Массив();
			КонецЕсли;
			
			// Не устанавливаем объектную блокировку на задачу Задача для того, чтобы 
			// позволить выполнять перенаправление по команде из формы этой задачи.
			ЗадачаОбъект = Задача.Ключ.ПолучитьОбъект();
			
			УстановитьПривилегированныйРежим(Истина);
			НоваяЗадача = Задачи.ЗадачаИсполнителя.СоздатьЗадачу();
			НоваяЗадача.Заполнить(ЗадачаОбъект);
			ЗаполнитьЗначенияСвойств(НоваяЗадача, ИнфоОПеренаправлении, 
				"Исполнитель,РольИсполнителя,ОсновнойОбъектАдресации,ДополнительныйОбъектАдресации");
			НоваяЗадача.Записать();
			УстановитьПривилегированныйРежим(Ложь);
		
			МассивПеренаправленныхЗадач.Добавить(НоваяЗадача.Ссылка);
			
			ЗадачаОбъект.РезультатВыполнения = ИнфоОПеренаправлении.Комментарий; 
			ЗадачаОбъект.Выполнена = Ложь;
			ЗадачаОбъект.ДополнительныеСвойства.Вставить("Перенаправление", Истина);
			ЗадачаОбъект.ВыполнитьЗадачу();
			
			УстановитьПривилегированныйРежим(Истина);
			ПодчиненныеБизнесПроцессы = БизнесПроцессыИЗадачиСервер.ВыбратьБизнесПроцессыВедущейЗадачи(Задача.Ключ, Истина).Выбрать();
			УстановитьПривилегированныйРежим(Ложь);
			Пока ПодчиненныеБизнесПроцессы.Следующий() Цикл
				БизнесПроцессОбъект = ПодчиненныеБизнесПроцессы.Ссылка.ПолучитьОбъект();
				БизнесПроцессОбъект.ВедущаяЗадача = НоваяЗадача.Ссылка;
				БизнесПроцессОбъект.Записать();
			КонецЦикла;
			
			ПодчиненныеБизнесПроцессы = БизнесПроцессыИЗадачиСервер.БизнесПроцессыГлавнойЗадачи(Задача.Ключ, Истина);
			Для каждого ПодчиненныйБизнесПроцесс Из ПодчиненныеБизнесПроцессы Цикл
				БизнесПроцессОбъект = ПодчиненныйБизнесПроцесс.ПолучитьОбъект();
				БизнесПроцессОбъект.ГлавнаяЗадача = НоваяЗадача.Ссылка;
				БизнесПроцессОбъект.Записать();
			КонецЦикла;
			
			ПриПеренаправленииЗадачи(ЗадачаОбъект, НоваяЗадача);
				
		КонецЦикла;
			
		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();
		Результат = Ложь;
		Если Не ТолькоПроверка Тогда
			ВызватьИсключение;
		КонецЕсли;
	КонецПопытки;
	
	Возврат Результат;
	
КонецФункции

// Отмечает указанные бизнес-процессы как активные.
//
// Параметры:
//  БизнесПроцессы - Массив - массив ссылок на бизнес-процессы.
//
Процедура СделатьАктивнымБизнесПроцессы(БизнесПроцессы) Экспорт
	
	НачатьТранзакцию();
	Попытка
		БизнесПроцессыИЗадачиСервер.ЗаблокироватьБизнесПроцессы(БизнесПроцессы);
		
		Для каждого БизнесПроцесс Из БизнесПроцессы Цикл
			СделатьАктивнымБизнесПроцесс(БизнесПроцесс);
		КонецЦикла;
		
		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();
		ВызватьИсключение;
	КонецПопытки;
	
КонецПроцедуры

// Отмечает указанный бизнес-процесс как активный.
//
// Параметры:
//  БизнесПроцесс - БизнесПроцессСсылка - ссылка на бизнес-процесс.
//
Процедура СделатьАктивнымБизнесПроцесс(БизнесПроцесс) Экспорт
	
	Если ТипЗнч(БизнесПроцесс) = Тип("СтрокаГруппировкиДинамическогоСписка") Тогда
		Возврат;
	КонецЕсли;
	
	НачатьТранзакцию();
	Попытка
		БизнесПроцессыИЗадачиСервер.ЗаблокироватьБизнесПроцессы(БизнесПроцесс);
		
		Объект = БизнесПроцесс.ПолучитьОбъект();
		Если Объект.Состояние = Перечисления.СостоянияБизнесПроцессов.Активен Тогда
			
			Если Объект.Завершен Тогда
				ВызватьИсключение НСтр("ru = 'Невозможно сделать активными завершенные бизнес-процессы.'");
			КонецЕсли;
			
			Если Не Объект.Стартован Тогда
				ВызватьИсключение НСтр("ru = 'Невозможно сделать активными не стартовавшие бизнес-процессы.'");
			КонецЕсли;
			
			ВызватьИсключение НСтр("ru = 'Бизнес-процесс уже активен.'");
		КонецЕсли;
			
		Объект.Заблокировать();
		Объект.Состояние = Перечисления.СостоянияБизнесПроцессов.Активен;
		Объект.Записать(); // АПК:1327 Блокировка установлена ранее в БизнесПроцессыИЗадачиСервер.ЗаблокироватьБизнесПроцессы.
		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();
		ВызватьИсключение;
	КонецПопытки;
	
КонецПроцедуры

// Отмечает указанные бизнес-процессы как остановленные.
//
// Параметры:
//  БизнесПроцессы - Массив - массив ссылок на бизнес-процессы.
//
Процедура ОстановитьБизнесПроцессы(БизнесПроцессы) Экспорт
	
	НачатьТранзакцию();
	Попытка 
		БизнесПроцессыИЗадачиСервер.ЗаблокироватьБизнесПроцессы(БизнесПроцессы);
		
		Для каждого БизнесПроцесс Из БизнесПроцессы Цикл
			ОстановитьБизнесПроцесс(БизнесПроцесс);
		КонецЦикла;
		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();
		ЗаписьЖурналаРегистрации(БизнесПроцессыИЗадачиСервер.СобытиеЖурналаРегистрации(), УровеньЖурналаРегистрации.Ошибка,,, 
			ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
		ВызватьИсключение;
	КонецПопытки;
	
КонецПроцедуры

// Отмечает указанный бизнес-процесс как остановленный.
//
// Параметры:
//  БизнесПроцесс - БизнесПроцессСсылка - ссылка на бизнес-процесс.
//
Процедура ОстановитьБизнесПроцесс(БизнесПроцесс) Экспорт
	
	Если ТипЗнч(БизнесПроцесс) = Тип("СтрокаГруппировкиДинамическогоСписка") Тогда
		Возврат;
	КонецЕсли;
	
	НачатьТранзакцию();
	Попытка
		БизнесПроцессыИЗадачиСервер.ЗаблокироватьБизнесПроцессы(БизнесПроцесс);
		
		Объект = БизнесПроцесс.ПолучитьОбъект();
		Если Объект.Состояние = Перечисления.СостоянияБизнесПроцессов.Остановлен Тогда
			
			Если Объект.Завершен Тогда
				ВызватьИсключение НСтр("ru = 'Невозможно остановить завершенные бизнес-процессы.'");
			КонецЕсли;
				
			Если Не Объект.Стартован Тогда
				ВызватьИсключение НСтр("ru = 'Невозможно остановить не стартовавшие бизнес-процессы.'");
			КонецЕсли;
			
			ВызватьИсключение НСтр("ru = 'Бизнес-процесс уже остановлен.'");
		КонецЕсли;
		
		Объект.Заблокировать();
		Объект.Состояние = Перечисления.СостоянияБизнесПроцессов.Остановлен;
		Объект.Записать(); // АПК:1327 Блокировка установлена ранее в БизнесПроцессыИЗадачиСервер.ЗаблокироватьБизнесПроцессы.
		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();
		ВызватьИсключение;
	КонецПопытки;
	
КонецПроцедуры

// Отмечает указанные задачи как принятые к исполнению.
//
// Параметры:
//   Задачи - Массив - массив ссылок на задачи.
//
Процедура ПринятьЗадачиКИсполнению(Задачи) Экспорт
	
	НовыйМассивЗадач = Новый Массив();
	
	НачатьТранзакцию();
	Попытка
		БизнесПроцессыИЗадачиСервер.ЗаблокироватьЗадачи(Задачи);
		
		Для каждого Задача Из Задачи Цикл
			
			Если ТипЗнч(Задача) = Тип("СтрокаГруппировкиДинамическогоСписка") Тогда
				Продолжить;
			КонецЕсли;
			
			ЗадачаОбъект = Задача.ПолучитьОбъект();
			Если ЗадачаОбъект.Выполнена Тогда
				Продолжить;
			КонецЕсли;
			
			ЗадачаОбъект.Заблокировать();
			ЗадачаОбъект.ПринятаКИсполнению = Истина;
			ЗадачаОбъект.ДатаПринятияКИсполнению = ТекущаяДатаСеанса();
			Если НЕ ЗначениеЗаполнено(ЗадачаОбъект.Исполнитель) Тогда
				ЗадачаОбъект.Исполнитель = Пользователи.АвторизованныйПользователь();
			КонецЕсли;
			ЗадачаОбъект.Записать(); // АПК:1327 Блокировка установлена ранее в БизнесПроцессыИЗадачиСервер.ЗаблокироватьЗадачи.
			
			НовыйМассивЗадач.Добавить(Задача);
			
		КонецЦикла;
		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();
		ВызватьИсключение;
	КонецПопытки;
	
	Задачи = НовыйМассивЗадач;
	
КонецПроцедуры

// Отмечает указанные задачи как не принятые к исполнению.
//
// Параметры:
//   Задачи - Массив - массив ссылок на задачи.
//
Процедура ОтменитьПринятиеЗадачКИсполнению(Задачи) Экспорт
	
	НовыйМассивЗадач = Новый Массив();
	
	НачатьТранзакцию();
	Попытка
		БизнесПроцессыИЗадачиСервер.ЗаблокироватьЗадачи(Задачи);
			
		Для каждого Задача Из Задачи Цикл
			
			Если ТипЗнч(Задача) = Тип("СтрокаГруппировкиДинамическогоСписка") Тогда 
				Продолжить;
			КонецЕсли;	
			
			ЗадачаОбъект = Задача.ПолучитьОбъект();
			Если ЗадачаОбъект.Выполнена Тогда
				Продолжить;
			КонецЕсли;
			
			ЗадачаОбъект.Заблокировать();
			ЗадачаОбъект.ПринятаКИсполнению = Ложь;
			ЗадачаОбъект.ДатаПринятияКИсполнению = "00010101000000";
			Если Не ЗадачаОбъект.РольИсполнителя.Пустая() Тогда
				ЗадачаОбъект.Исполнитель = Справочники.Пользователи.ПустаяСсылка();
			КонецЕсли;
			ЗадачаОбъект.Записать(); // АПК:1327 Блокировка установлена ранее в БизнесПроцессыИЗадачиСервер.ЗаблокироватьЗадачи.
			
			НовыйМассивЗадач.Добавить(Задача);
			
		КонецЦикла;
		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();
		ВызватьИсключение;
	КонецПопытки;
	
	Задачи = НовыйМассивЗадач;
	
КонецПроцедуры

// Проверяет, является ли указанная задача ведущей.
//
// Параметры:
//  ЗадачаСсылка  - ЗадачаСсылка.ЗадачаИсполнителя - задача.
//
// Возвращаемое значение:
//   Булево - Если Истина, то задача является ведущей.
//
Функция ЭтоВедущаяЗадача(ЗадачаСсылка) Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	Результат = БизнесПроцессыИЗадачиСервер.ВыбратьБизнесПроцессыВедущейЗадачи(ЗадачаСсылка);
	Возврат НЕ Результат.Пустой();
	
КонецФункции

// Формирует список подбора для указания исполнителя в полях
//  ввода составного типа (Пользователь и Роль).
//
// Параметры:
//  Текст         - Строка - Фрагмент текста для поиска возможных исполнителей.
// 
// Возвращаемое значение:
//  СписокЗначений - Список подбора, содержащий возможных исполнителей.
//
Функция СформироватьДанныеВыбораИсполнителя(Текст) Экспорт
	
	ДанныеВыбора = Новый СписокЗначений;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ РАЗРЕШЕННЫЕ
	|	Пользователи.Ссылка КАК Ссылка
	|ИЗ
	|	Справочник.Пользователи КАК Пользователи
	|ГДЕ
	|	Пользователи.Наименование ПОДОБНО &Текст
	|	И Пользователи.Недействителен = ЛОЖЬ
	|	И Пользователи.Служебный = ЛОЖЬ
	|	И Пользователи.ПометкаУдаления = ЛОЖЬ
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	РолиИсполнителей.Ссылка
	|ИЗ
	|	Справочник.РолиИсполнителей КАК РолиИсполнителей
	|ГДЕ
	|	РолиИсполнителей.Наименование ПОДОБНО &Текст
	|	И НЕ РолиИсполнителей.ПометкаУдаления";
	Запрос.УстановитьПараметр("Текст", Текст + "%");
	
	Выборка = Запрос.Выполнить().Выбрать();
	Пока Выборка.Следующий() Цикл
		ДанныеВыбора.Добавить(Выборка.Ссылка);
	КонецЦикла;
	
	Возврат ДанныеВыбора;
	
КонецФункции

#КонецОбласти


#Область СлужебныеПроцедурыИФункции

////////////////////////////////////////////////////////////////////////////////
// Прочие служебные процедуры и функции.

// Возвращает число невыполненных задач по указанным бизнес-процессам.
//
Функция КоличествоНевыполненныхЗадачБизнесПроцессов(БизнесПроцессы) Экспорт
	
	КоличествоЗадач = 0;
	
	Для каждого БизнесПроцесс Из БизнесПроцессы Цикл
		
		Если ТипЗнч(БизнесПроцесс) = Тип("СтрокаГруппировкиДинамическогоСписка") Тогда
			Продолжить;
		КонецЕсли;
		
		КоличествоЗадач = КоличествоЗадач + КоличествоНевыполненныхЗадачБизнесПроцесса(БизнесПроцесс);
		
	КонецЦикла;
		
	Возврат КоличествоЗадач;
	
КонецФункции

// Возвращает число невыполненных задач по указанному бизнес-процессу.
//
Функция КоличествоНевыполненныхЗадачБизнесПроцесса(БизнесПроцесс) Экспорт
	
	Если ТипЗнч(БизнесПроцесс) = Тип("СтрокаГруппировкиДинамическогоСписка") Тогда
		Возврат 0;
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	КОЛИЧЕСТВО(*) КАК Количество
	               |ИЗ
	               |	Задача.ЗадачаИсполнителя КАК Задачи
	               |ГДЕ
	               |	Задачи.БизнесПроцесс = &БизнесПроцесс
	               |	И Задачи.Выполнена = ЛОЖЬ";
				   
	Запрос.УстановитьПараметр("БизнесПроцесс", БизнесПроцесс);
	
	Выборка = Запрос.Выполнить().Выбрать();
	Выборка.Следующий();
	
	Возврат Выборка.Количество;
	
КонецФункции

// Помечает на удаление указанные бизнес-процессы.
//
Функция ПометитьНаУдалениеБизнесПроцессы(ВыделенныеСтроки) Экспорт
	Количество = 0;
	Для Каждого СтрокаТаблицы Из ВыделенныеСтроки Цикл
		БизнесПроцессСсылка = СтрокаТаблицы.Владелец;
		Если БизнесПроцессСсылка = Неопределено ИЛИ БизнесПроцессСсылка.Пустая() Тогда
			Продолжить;
		КонецЕсли;
		НачатьТранзакцию();
		Попытка
			БизнесПроцессыИЗадачиСервер.ЗаблокироватьБизнесПроцессы(БизнесПроцессСсылка);
			БизнесПроцессОбъект = БизнесПроцессСсылка.ПолучитьОбъект();
			БизнесПроцессОбъект.УстановитьПометкуУдаления(НЕ БизнесПроцессОбъект.ПометкаУдаления);
			ЗафиксироватьТранзакцию();
		Исключение
			ОтменитьТранзакцию();
			ВызватьИсключение;
		КонецПопытки;
		
		Количество = Количество + 1;
	КонецЦикла;
	Возврат ?(Количество = 1, ВыделенныеСтроки[0].Владелец, Неопределено);
КонецФункции

Процедура ПриПеренаправленииЗадачи(ЗадачаОбъект, НоваяЗадачаОбъект) 
	
	Если ЗадачаОбъект.БизнесПроцесс.Пустая() Тогда
		Возврат;
	КонецЕсли;
	
	ПодключенныеБизнесПроцессы = Новый Соответствие;
	ПодключенныеБизнесПроцессы.Вставить(Метаданные.БизнесПроцессы.Задание.ПолноеИмя(), "");
	БизнесПроцессыИЗадачиПереопределяемый.ПриОпределенииБизнесПроцессов(ПодключенныеБизнесПроцессы);
	
	ТипБизнесПроцесса = ЗадачаОбъект.БизнесПроцесс.Метаданные();
	СведенияОБизнесПроцессе = ПодключенныеБизнесПроцессы[ТипБизнесПроцесса.ПолноеИмя()];
	Если СведенияОБизнесПроцессе <> Неопределено Тогда 
		БизнесПроцессы[ТипБизнесПроцесса.Имя].ПриПеренаправленииЗадачи(ЗадачаОбъект.Ссылка, НоваяЗадачаОбъект.Ссылка);
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти
