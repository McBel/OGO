///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2019, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ПрограммныйИнтерфейс

// Определяет форму ФИО в заданном падеже.
//
// Параметры:
// 	ФИО		- Строка - Строка, в которой содержится ФИО для склонения.
// 	Падеж 	- Число - падеж, в который необходимо просклонять представление объекта.
//							1 - Именительный.
//							2 - Родительный.
//							3 - Дательный.
//							4 - Винительный.
//							5 - Творительный.
//							6 - Предложный.
//	Объект 	- ОбъектСклонения - Ссылка на объект, реквизит которого склоняется.
//	Пол		- Число - Число - пол физического лица, 
//							1 - мужской, 
//							2 - женский.
//
// Возвращаемое значение:
//	Строка - Результат склонения ФИО в падеже.
//
Функция ПросклонятьФИО(ФИО, Падеж, Объект = Неопределено, Пол = Неопределено) Экспорт
	
	ПараметрыСклонения = СклонениеПредставленийОбъектовКлиентСервер.ПараметрыСклонения();
	ПараметрыСклонения.ЭтоФИО = Истина;
	ПараметрыСклонения.Пол = Пол;
	
	Возврат Просклонять(ФИО, Падеж, Объект, ПараметрыСклонения);
	
КонецФункции

// Склоняет представление объекта.
//
// Параметры:
// 	Представление 	- Строка 	- Строка, в которой содержится ФИО для склонения.
// 	Падеж 			- Число  	- падеж, в который необходимо просклонять представление объекта.
//  	               			1 - Именительный.
//                  			2 - Родительный.
//                  			3 - Дательный.
//                  			4 - Винительный.
//                  			5 - Творительный.
//                  			6 - Предложный.
//  Объект 	- ОбъектСклонения 	- Ссылка на объект, реквизит которого склоняется.
//
// Возвращаемое значение:
//  Строка - Результат склонения представления объекта в падеже.
//
Функция ПросклонятьПредставление(Представление, Падеж, Объект = Неопределено) Экспорт
	
	Возврат Просклонять(Представление, Падеж, Объект);
	
КонецФункции

// Выполняет с формой действия, необходимые для подключения подсистемы Склонения.
//
// Параметры:
//  Форма - ФормаКлиентскогоПриложения - форма для подключения механизма склонения.
//  Представление - Строка - Строка для склонения.
//  ИмяОсновногоРеквизитаФормы - Строка - Имя основного реквизита формы. 
//
Процедура ПриСозданииНаСервере(Форма, Представление, ИмяОсновногоРеквизитаФормы = "Объект") Экспорт
	
	МассивРеквизитов = Новый Массив;
	
	ЗаголовокРеквизита = НСтр("ru = 'Изменено представление'");
	РеквизитИзмененоПредставление = Новый РеквизитФормы("ИзмененоПредставление", Новый ОписаниеТипов("Булево"), , ЗаголовокРеквизита);
	МассивРеквизитов.Добавить(РеквизитИзмененоПредставление);
	
	РеквизитСклонения = Новый РеквизитФормы("Склонения", Новый ОписаниеТипов(), , "Склонения");
	МассивРеквизитов.Добавить(РеквизитСклонения);
	
	Форма.ИзменитьРеквизиты(МассивРеквизитов);
	
	СтруктураСклонения = СклоненияИзРегистра(Представление, Форма[ИмяОсновногоРеквизитаФормы].Ссылка);
	Если СтруктураСклонения <> Неопределено Тогда
		Форма.Склонения = Новый ФиксированнаяСтруктура(СтруктураСклонения);
	КонецЕсли;
	
КонецПроцедуры

// Обработчик события ПриЗаписиНаСервере управляемой формы объекта для склонения.
//
// Параметры:
//  Форма				 - ФормаКлиентскогоПриложения	 - форма объекта склонения.
//  Представление		 - Строка			 - Строка для склонения.
//  Объект				 - ОбъектСклонения	 - Объект для склонения.
//  ПараметрыСклонения	 - Структура		 - необязательный, дополнительные параметры склонения,
//  		см. СклонениеПредставленийОбъектовКлиентСервер.ПараметрыСклонения().
//
Процедура ПриЗаписиФормыОбъектаСклонения(Форма, Представление, Объект, ПараметрыСклонения = Неопределено) Экспорт

	Если Форма.ИзмененоПредставление Тогда
		СтруктураСклонений = ПросклонятьПредставлениеПоВсемПадежам(Представление, ПараметрыСклонения);
		Форма.Склонения = Новый ФиксированнаяСтруктура(СтруктураСклонений);
		Форма.ИзмененоПредставление = Ложь;
	КонецЕсли;
	
	Если ТипЗнч(Форма.Склонения) = Тип("ФиксированнаяСтруктура") Тогда
		ЗаписатьВРегистрСклонения(Представление, Объект, Форма.Склонения);
	КонецЕсли;
	
КонецПроцедуры

// Устанавливает признак доступности сервиса склонения.
//
// Параметры:
//  Доступность	- Булево - Признак доступности сервиса склонения.
//
Процедура УстановитьДоступностьСервисаСклонения(Доступность) Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	ТекущиеПараметры = Новый Соответствие(ПараметрыСеанса.ПараметрыКлиентаНаСервере);
	ТекущиеПараметры.Вставить("ДоступенСервисСклонения", Доступность);
	ПараметрыСеанса.ПараметрыКлиентаНаСервере = Новый ФиксированноеСоответствие(ТекущиеПараметры);
	
КонецПроцедуры

// Определяет доступен ли сервис склонения.
// 
// Возвращаемое значение: 
//	Булево  - Истина, если веб-сервис склонения доступен.
//
Функция ДоступенСервисСклонения() Экспорт
	
	Результат = ПараметрыСеанса.ПараметрыКлиентаНаСервере.Получить("ДоступенСервисСклонения");
	
	Если Результат = Неопределено Тогда
		Возврат Истина;
	Иначе 
		Возврат Результат;
	КонецЕсли;
	
КонецФункции

#Область УстаревшиеПроцедурыИФункции

// Устарела. Следует использовать СклонениеПредставленийОбъектов.ПриЗаписиФормыОбъектаСклонения.
// Обработчик события ПриЗаписиНаСервере управляемой формы объекта для склонения.
//
// Параметры:
//  Форма 			- ФормаКлиентскогоПриложения - форма объекта склонения.
//  Представление   - Строка - Строка для склонения.
//  Объект 			- ОбъектСклонения - Объект для склонения.
//  ЭтоФИО       	- Булево - Признак склонения ФИО.
//	Пол				- Число	- Пол физического лица (в случае склонения ФИО)
//							1 - мужской 
//							2 - женский.
//
Процедура ПриЗаписиНаСервере(Форма, Представление, Объект, ЭтоФИО = Ложь, Пол = Неопределено) Экспорт
	
	ПараметрыСклонения = СклонениеПредставленийОбъектовКлиентСервер.ПараметрыСклонения();
	ПараметрыСклонения.ЭтоФИО = ЭтоФИО;
	ПараметрыСклонения.Пол = Пол;
	
	ПриЗаписиФормыОбъектаСклонения(Форма, Представление, Объект, ПараметрыСклонения);
	
КонецПроцедуры

// Устарела. Следует использовать СклонениеПредставленийОбъектов.ПросклонятьФИО.
//
// Склоняет переданную фразу.
// Только для работы на ОС Windows.
//
// Параметры:
//  ФИО   - Строка - фамилия, имя и отчество в именительном падеже, 
//                   которые необходимо просклонять.
//  Падеж - Число  - падеж, в который необходимо поставить ФИО:
//                   1 - Именительный.
//                   2 - Родительный.
//                   3 - Дательный.
//                   4 - Винительный.
//                   5 - Творительный.
//                   6 - Предложный.
//  Результат - Строка - в этот параметр помещается результат склонения.
//                       Если ФИО не удалось просклонять, то возвращается значение ФИО.
//  Пол       - Число - пол физического лица, 1 - мужской, 2 - женский.
//
// Возвращаемое значение:
//   Булево - Истина, если ФИО удалось просклонять.
//
Функция ПросклонятьФИОСПомощьюКомпоненты(Знач ФИО, Падеж, Результат, Пол = Неопределено) Экспорт
	
	ПроверитьПараметрПол(Пол, "СклонениеПредставленийОбъектов.ПросклонятьФИОСПомощьюКомпоненты");
	ПроверитьПараметрПадеж(Падеж, "СклонениеПредставленийОбъектов.ПросклонятьФИОСПомощьюКомпоненты");
	
	Результат = ПросклонятьФИО(ФИО, Падеж, , Пол);
	
	Возврат Истина;
	
КонецФункции

#КонецОбласти

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Склоняет представление объекта.
// Только для работы на ОС Windows.
//
// Параметры:
// 	Объект	- ОбъектСклонения 	- Ссылка на объект, в котором содержится реквизит для склонения.
// 	ВидПредставления - Строка 	- Имя реквизита объекта для склонения.
// 	Падеж 	- Число  			- падеж, в который необходимо просклонять представление объекта.
//                  			1 - Именительный.
//                  			2 - Родительный.
//                  			3 - Дательный.
//                  			4 - Винительный.
//                  			5 - Творительный.
//                  			6 - Предложный.
//
// Возвращаемое значение:
//  	Строка - Результат склонения представления объекта в падеже.
//
Функция Просклонять(Представление, Падеж, Объект = Неопределено, ПараметрыСклонения = Неопределено) 
	
	ИмяПадежа = СоответствиеПадежей().Получить(Падеж);
	ПроверитьПараметрПадеж(Падеж, "СклонениеПредставленийОбъектов.Просклонять");
	
	СтруктураСклоненияИзРегистра = СклоненияИзРегистра(Представление, Объект);
	
	Если СтруктураСклоненияИзРегистра <> Неопределено И ЗначениеЗаполнено(СтруктураСклоненияИзРегистра[ИмяПадежа]) Тогда
		Возврат СтруктураСклоненияИзРегистра[ИмяПадежа];
	КонецЕсли;
	
	СтруктураСклонения = ДанныеСклонения(Представление, ПараметрыСклонения);
	
	Если ЗначениеЗаполнено(Объект) Тогда
		ЗаписатьВРегистрСклонения(Представление, Объект, СтруктураСклонения);
	КонецЕсли;
	
	Возврат СтруктураСклонения[ИмяПадежа];
	
КонецФункции

// Склоняет переданную фразу по всем падежам.
//
// Параметры:
//  Представление   - Строка - Строка для склонения.
//  ЭтоФИО       	- Булево - Признак склонения ФИО.
//	Пол				- Число	- Пол физического лица (в случае склонения ФИО): 1 - мужской, 2 - женский.
//  ПоказыватьСообщения - Булево - Признак, определяющий нужно ли показывать пользователю сообщения об ошибках.
//
// Возвращаемое значение:
//	 Структура - со свойствами:
//		* Именительный - Строка.
//		* Родительный 	- Строка.
//		* Дательный 	- Строка.
//		* Винительный 	- Строка.
//		* Творительный - Строка.
//		* Предложный 	- Строка.
//
Функция ПросклонятьПредставлениеПоВсемПадежам(Представление, ПараметрыСклонения = Неопределено, ПоказыватьСообщения = Ложь)
	
	СтруктураСклонения = СклоненияИзРегистра(Представление);
	
	Если СтруктураСклонения <> Неопределено Тогда
		Возврат СтруктураСклонения;
	КонецЕсли;
	
	СтруктураСклонения = ДанныеСклонения(Представление, ПараметрыСклонения, ПоказыватьСообщения);
	
	Возврат СтруктураСклонения;
	
КонецФункции

Процедура ПросклонятьПредставлениеПоВсемПадежамДлительнаяОперация(Параметры, АдресРезультата) Экспорт
	
	СтруктураСклонения = ПросклонятьПредставлениеПоВсемПадежам(Параметры.Представление, Параметры.ПараметрыСклонения, Истина);
	ПоместитьВоВременноеХранилище(СтруктураСклонения, АдресРезультата);
	
КонецПроцедуры

// Получает данные склонения по всем падежам.
//
// Параметры:
//  Представление   - Строка - Строка для склонения.
//  ЭтоФИО          - Булево - Признак склонения ФИО.
//  Пол             - Число  - Пол физического лица (в случае склонения ФИО)
//                             1 - мужской 
//                             2 - женский.
//  ПоказыватьСообщения - Булево - Признак, определяющий нужно ли показывать пользователю сообщения об ошибках.
//
// Возвращаемое значение:
//   Структура - со свойствами:
//      * Именительный - Строка.
//      * Родительный  - Строка.
//      * Дательный    - Строка
//      * Винительный  - Строка.
//      * Творительный - Строка.
//      * Предложный   - Строка.
//
Функция ДанныеСклонения(Представление, ПараметрыСклонения = Неопределено, ПоказыватьСообщения = Ложь) Экспорт
	
	СтруктураСклонения = СклонениеПредставленийОбъектовКлиентСервер.СтруктураСклонения();
	
	Если Не ЗначениеЗаполнено(Представление) Тогда
		Возврат СтруктураСклонения;
	КонецЕсли;
	
	СтандартнаяОбработка = Истина;
	
	ПросклонятьСПомощьюСервисаСклоненияMorpher(СтруктураСклонения, Представление, СтандартнаяОбработка);
	
	Если Не СтандартнаяОбработка Тогда
		Возврат СтруктураСклонения;
	КонецЕсли;
	
	ОписаниеСтроки = Неопределено;
	ЗаполнитьОписаниеСтрокиПоПараметрамСклонения(ОписаниеСтроки, ПараметрыСклонения, "СклонениеПредставленийОбъектов.ДанныеСклонения");
	
	ИменаПадежей = ОбщегоНазначения.ВыгрузитьКолонку(СтруктураСклонения, "Ключ");
	ОбщегоНазначенияКлиентСервер.УдалитьЗначениеИзМассива(ИменаПадежей, "Именительный");
	
	СтруктураСклонения["Именительный"] = Представление;
	Для Каждого ИмяПадежа Из ИменаПадежей Цикл
		ВариантыСклонения = ПолучитьСклоненияСтроки(Представление, ОписаниеСтроки, "ПД=" + ИмяПадежа);
		СтруктураСклонения[ИмяПадежа] = ВариантыСклонения[0];
	КонецЦикла;
	
	Возврат СтруктураСклонения;
	
КонецФункции

Процедура ЗаписатьВРегистрСклонения(Представление, Объект, Склонения) 
	
	Если Не Метаданные.ОпределяемыеТипы.ОбъектСклонения.Тип.СодержитТип(ТипЗнч(Объект)) Тогда
		Возврат;
	КонецЕсли;
	
	УстановитьОтключениеБезопасногоРежима(Истина);
	УстановитьПривилегированныйРежим(Истина);
	
	ХешПредставления = ОбщегоНазначения.КонтрольнаяСуммаСтрокой(Представление);
	НаборЗаписейСклонения = РегистрыСведений.СклоненияПредставленийОбъектов.СоздатьНаборЗаписей();
	НаборЗаписейСклонения.Отбор.Объект.Установить(Объект.Ссылка);
	
	НоваяСтрока = НаборЗаписейСклонения.Добавить();
	НоваяСтрока.Объект = Объект.Ссылка;
	НоваяСтрока.ХешПредставления = ХешПредставления;
	НоваяСтрока.ИменительныйПадеж = Склонения.Именительный;
	НоваяСтрока.РодительныйПадеж = Склонения.Родительный;
	НоваяСтрока.ДательныйПадеж = Склонения.Дательный;
	НоваяСтрока.ВинительныйПадеж = Склонения.Винительный;
	НоваяСтрока.ТворительныйПадеж = Склонения.Творительный;
	НоваяСтрока.ПредложныйПадеж = Склонения.Предложный;
	
	НаборЗаписейСклонения.Записать();
	
КонецПроцедуры

#Область СервисСклонений

Процедура ПросклонятьСПомощьюСервисаСклоненияMorpher(СтруктураСклонения, Представление, СтандартнаяОбработка)
	
	ИспользоватьСервисСклонения = Константы.ИспользоватьСервисСклоненияMorpher.Получить();
	Если Не ИспользоватьСервисСклонения Тогда
		Возврат;
	КонецЕсли;
	
	СклоненияЧерезСервис = СтруктураСклоненияЧерезЗапросКСервису(Представление, Ложь);
	Если СклоненияЧерезСервис = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	СтандартнаяОбработка = Ложь;
	ЗаполнитьЗначенияСвойств(СтруктураСклонения, СклоненияЧерезСервис);
	
КонецПроцедуры

Функция СтруктураСклоненияЧерезЗапросКСервису(СклоняемыйТекст, ПоказыватьСообщения) 
	
	Если Не ДоступенСервисСклонения() Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	УстановитьОтключениеБезопасногоРежима(Истина);
	
	Соединение = HTTPСоединениеСервисаСклонений();
	Запрос = HTTPЗапросКСервисуСклонения(СклоняемыйТекст);
	Попытка
		Ответ = ВыполнитьЗапросСервисуСклонений(Соединение, Запрос);
	Исключение
		ЗарегистрироватьОшибкуСервисаСклонений(ИнформацияОбОшибке(), ПоказыватьСообщения);
		УстановитьДоступностьСервисаСклонения(Ложь);
		Возврат Неопределено;
	КонецПопытки;
	УстановитьОтключениеБезопасногоРежима(Ложь);
	
	СтруктураОтвета = СтруктураОтветаСервисаСклонений(Ответ);
	
	СтруктураСклонения = СклонениеПредставленийОбъектовКлиентСервер.СтруктураСклонения();
	СтруктураСклонения.Именительный = СклоняемыйТекст;
	СтруктураСклонения.Родительный  = СтруктураОтвета.Р;
	СтруктураСклонения.Дательный    = СтруктураОтвета.Д;
	СтруктураСклонения.Винительный  = СтруктураОтвета.В;
	СтруктураСклонения.Творительный = СтруктураОтвета.Т;
	СтруктураСклонения.Предложный   = СтруктураОтвета.П;
	
	Возврат СтруктураСклонения;
	
КонецФункции

Функция HTTPСоединениеСервисаСклонений()
	
	АдресСервера = "ws3.morpher.ru";
	
	ИнтернетПрокси = Неопределено;
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.ПолучениеФайловИзИнтернета") Тогда
		МодульПолучениеФайловИзИнтернета = ОбщегоНазначения.ОбщийМодуль("ПолучениеФайловИзИнтернета");
		ИнтернетПрокси = МодульПолучениеФайловИзИнтернета.ПолучитьПрокси("https");
	КонецЕсли;
	
	Таймаут = 10;
	
	ЗащищенноеСоединение = ОбщегоНазначенияКлиентСервер.НовоеЗащищенноеСоединение();
	Возврат Новый HTTPСоединение(АдресСервера,,,, ИнтернетПрокси, Таймаут, ЗащищенноеСоединение);
	
КонецФункции

Функция HTTPЗапросКСервисуСклонения(СклоняемыйТекст)
	
	ТекстЗапроса = "/russian/declension?s=" + СклоняемыйТекст;
	
	УстановитьПривилегированныйРежим(Истина);
	ВладелецТокена = ОбщегоНазначения.ИдентификаторОбъектаМетаданных("РегистрСведений.СклоненияПредставленийОбъектов");
	Токен = ОбщегоНазначения.ПрочитатьДанныеИзБезопасногоХранилища(ВладелецТокена, "ТокенДоступаКСервисуMorpher", Истина);
	УстановитьПривилегированныйРежим(Ложь);
	
	Если ЗначениеЗаполнено(Токен) Тогда
		ТекстЗапроса = ТекстЗапроса + "&token=" + Токен;
	КонецЕсли;
	
	Заголовки = Новый Соответствие;
	Заголовки.Вставить("User-Agent", "1C Enterprise 8.3");
	Заголовки.Вставить("Accept", "application/json");
	Заголовки.Вставить("charset", "UTF-8");
	
	Возврат Новый HTTPЗапрос(ТекстЗапроса, Заголовки);
	
КонецФункции

Функция ВыполнитьЗапросСервисуСклонений(Соединение, Запрос)
	
	Попытка
		Ответ = Соединение.Получить(Запрос);
	Исключение
		
		Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.ПолучениеФайловИзИнтернета") Тогда
			МодульПолучениеФайловИзИнтернета = ОбщегоНазначения.ОбщийМодуль("ПолучениеФайловИзИнтернета");
			РезультатДиагностики = МодульПолучениеФайловИзИнтернета.ДиагностикаСоединения(Соединение.Сервер);
			ВызватьИсключение СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = '%1
				           |
				           |Результат диагностики:
				           |%2'"),
				КраткоеПредставлениеОшибки(ИнформацияОбОшибке()),
				РезультатДиагностики.ОписаниеОшибки);
		Иначе 
			ВызватьИсключение;
		КонецЕсли
		
	КонецПопытки;
	
	Если Ответ.КодСостояния <> 200 Тогда
		ВызватьИсключение СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Ошибка при обработке запроса к ресурсу:
			           |%1'"),
			Ответ.ПолучитьТелоКакСтроку());
	КонецЕсли;
		
	Возврат Ответ;
	
КонецФункции

Функция СтруктураОтветаСервисаСклонений(Ответ)
	
	ЧтениеJSON = Новый ЧтениеJSON;
	ЧтениеJSON.УстановитьСтроку(Ответ.ПолучитьТелоКакСтроку());
	Результат = ПрочитатьJSON(ЧтениеJSON);
	ЧтениеJSON.Закрыть();
	
	Возврат Результат;
	
КонецФункции

Процедура ЗарегистрироватьОшибкуСервисаСклонений(ИнформацияОбОшибке, ПоказыватьСообщения)
	
	// АПК:154-выкл Ошибка при вызове сервиса склонений не является критичной.
	
	ИмяСобытия = НСтр("ru = 'Вызов веб-сервиса склонения'", ОбщегоНазначения.КодОсновногоЯзыка());
	ЗаписьЖурналаРегистрации(ИмяСобытия, УровеньЖурналаРегистрации.Предупреждение,,, 
		ПодробноеПредставлениеОшибки(ИнформацияОбОшибке));
	
	// АПК:154-вкл
	
	Если Не ПоказыватьСообщения Тогда
		Возврат;
	КонецЕсли;
	
	ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
		НСтр("ru = 'Ошибка при вызове сервиса склонения. Обратитесь к администратору.
			       |Техническая информация:
			       |%1'"), 
		КраткоеПредставлениеОшибки(ИнформацияОбОшибке));
	
	ОбщегоНазначения.СообщитьПользователю(ТекстСообщения);
	
КонецПроцедуры

#КонецОбласти

Функция СклоненияИзРегистра(Представление, Объект = Неопределено)
	
	УстановитьОтключениеБезопасногоРежима(Истина);
	УстановитьПривилегированныйРежим(Истина);
	
	СтруктураСклонения = Неопределено;
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ХешПредставления", ОбщегоНазначения.КонтрольнаяСуммаСтрокой(Представление));
	Запрос.УстановитьПараметр("Объект", Объект);
	Запрос.УстановитьПараметр("ИспользуетсяОтборПоОбъекту", Объект <> Неопределено);
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	КОЛИЧЕСТВО(ВЫРАЗИТЬ(СклоненияПредставленийОбъектов.ИменительныйПадеж КАК СТРОКА(255))) КАК КоличествоНаборовСклонений,
		|	СклоненияПредставленийОбъектов.ХешПредставления КАК ХешПредставления
		|ПОМЕСТИТЬ ТаблицаРегистраБезОтбораПоОбъекту
		|ИЗ
		|	РегистрСведений.СклоненияПредставленийОбъектов КАК СклоненияПредставленийОбъектов
		|ГДЕ
		|	СклоненияПредставленийОбъектов.ХешПредставления = &ХешПредставления
		|
		|СГРУППИРОВАТЬ ПО
		|	СклоненияПредставленийОбъектов.ХешПредставления
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	СклоненияПредставленийОбъектов.ИменительныйПадеж КАК Именительный,
		|	СклоненияПредставленийОбъектов.РодительныйПадеж КАК Родительный,
		|	СклоненияПредставленийОбъектов.ДательныйПадеж КАК Дательный,
		|	СклоненияПредставленийОбъектов.ВинительныйПадеж КАК Винительный,
		|	СклоненияПредставленийОбъектов.ТворительныйПадеж КАК Творительный,
		|	СклоненияПредставленийОбъектов.ПредложныйПадеж КАК Предложный,
		|	0 КАК Приоритет
		|ИЗ
		|	РегистрСведений.СклоненияПредставленийОбъектов КАК СклоненияПредставленийОбъектов
		|ГДЕ
		|	&ИспользуетсяОтборПоОбъекту
		|	И СклоненияПредставленийОбъектов.Объект = &Объект
		|	И СклоненияПредставленийОбъектов.ХешПредставления = &ХешПредставления
		|
		|ОБЪЕДИНИТЬ ВСЕ
		|
		|ВЫБРАТЬ
		|	СклоненияПредставленийОбъектов.ИменительныйПадеж,
		|	СклоненияПредставленийОбъектов.РодительныйПадеж,
		|	СклоненияПредставленийОбъектов.ДательныйПадеж,
		|	СклоненияПредставленийОбъектов.ВинительныйПадеж,
		|	СклоненияПредставленийОбъектов.ТворительныйПадеж,
		|	СклоненияПредставленийОбъектов.ПредложныйПадеж,
		|	1
		|ИЗ
		|	РегистрСведений.СклоненияПредставленийОбъектов КАК СклоненияПредставленийОбъектов
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ТаблицаРегистраБезОтбораПоОбъекту КАК ТаблицаРегистраБезОтбораПоОбъекту
		|		ПО СклоненияПредставленийОбъектов.ХешПредставления = ТаблицаРегистраБезОтбораПоОбъекту.ХешПредставления
		|			И (ТаблицаРегистраБезОтбораПоОбъекту.КоличествоНаборовСклонений = 1)
		|ГДЕ
		|	СклоненияПредставленийОбъектов.ХешПредставления = &ХешПредставления
		|
		|УПОРЯДОЧИТЬ ПО
		|	Приоритет";
	
	Выборка = Запрос.Выполнить().Выбрать();
	Если Выборка.Следующий() Тогда
		СтруктураСклонения = СклонениеПредставленийОбъектовКлиентСервер.СтруктураСклонения();
		ЗаполнитьЗначенияСвойств(СтруктураСклонения, Выборка);
	КонецЕсли;
	
	Возврат СтруктураСклонения;
	
КонецФункции

Функция СоответствиеПадежей()
	
	СоответствиеПадежей = Новый Соответствие;
	
	СоответствиеПадежей.Вставить(1, "Именительный");
	СоответствиеПадежей.Вставить(2, "Родительный");
	СоответствиеПадежей.Вставить(3, "Дательный");
	СоответствиеПадежей.Вставить(4, "Винительный");
	СоответствиеПадежей.Вставить(5, "Творительный");
	СоответствиеПадежей.Вставить(6, "Предложный");
	
	Возврат СоответствиеПадежей;
	
КонецФункции

Функция ЕстьПравоДоступаКОбъекту(Ссылка) Экспорт
	
	Возврат ПравоДоступа("Редактирование", Ссылка.Метаданные());
	
КонецФункции

Процедура ЗаполнитьОписаниеСтрокиПоПараметрамСклонения(ОписаниеСтроки, ПараметрыСклонения, ИмяПроцедурыИлиФункции)
	
	Если ПараметрыСклонения = Неопределено Тогда
		ПараметрыСклонения = СклонениеПредставленийОбъектовКлиентСервер.ПараметрыСклонения();
	КонецЕсли;
	
	ПроверитьПараметрыСклонения(ПараметрыСклонения, ИмяПроцедурыИлиФункции);
	
	Если Не ПараметрыСклонения.ЭтоФИО Тогда
		Возврат;
	КонецЕсли;
	
	Если ПараметрыСклонения.Пол = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Если ПараметрыСклонения.Пол = 1 Тогда
		ОписаниеСтроки = "ПЛ=Мужской";
	КонецЕсли;
	
	Если ПараметрыСклонения.Пол = 2 Тогда
		ОписаниеСтроки = "ПЛ=Женский";
	КонецЕсли;
	
КонецПроцедуры

Процедура ПроверитьПараметрыСклонения(ПараметрыСклонения, ИмяПроцедурыИлиФункции)
	
	ПроверитьПараметрЭтоФИО(ПараметрыСклонения.ЭтоФИО, ИмяПроцедурыИлиФункции);
	ПроверитьПараметрПол(ПараметрыСклонения.Пол, ИмяПроцедурыИлиФункции);
	
КонецПроцедуры

Процедура ПроверитьПараметрЭтоФИО(ЭтоФИО, ИмяПроцедурыИлиФункции)
	
	ОбщегоНазначенияКлиентСервер.ПроверитьПараметр(
		ИмяПроцедурыИлиФункции, "ЭтоФИО", ЭтоФИО, Тип("Булево"));
	
КонецПроцедуры

Процедура ПроверитьПараметрПол(Пол, ИмяПроцедурыИлиФункции)
	
	Если Пол = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ОбщегоНазначенияКлиентСервер.ПроверитьПараметр(
		ИмяПроцедурыИлиФункции, "Пол", Пол, Тип("Число"));
	
	ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
		НСтр("ru = 'Недопустимое значение параметра %1 в %2.
		           |параметр должен числом 1 (мужской) или 2 (женский); передано значение: %3 (тип %4).'"),
		"Пол", ИмяПроцедурыИлиФункции, Пол, ТипЗнч(Пол));
	ОбщегоНазначенияКлиентСервер.Проверить(Пол = 1 Или Пол = 2, ТекстСообщения);
	
КонецПроцедуры

Процедура ПроверитьПараметрПадеж(Падеж, ИмяПроцедурыИлиФункции)
	
	ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
		НСтр("ru = 'Недопустимое значение параметра Падеж в СклонениеПредставлениеОбъектов.Просклонять.
              |Параметр должен быть числом, обозначающим порядковый номер падежа, от 1 до 6.
              |Передано значение %1 (тип %2).'"),
		Падеж,
		ТипЗнч(Падеж));
		
	ОбщегоНазначенияКлиентСервер.Проверить(
		ТипЗнч(Падеж) = Тип("Число") И (Падеж >= 1 И Падеж <= 6), 
		ТекстСообщения, 
		ИмяПроцедурыИлиФункции);
	
КонецПроцедуры

#КонецОбласти