///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2019, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ПрограммныйИнтерфейс

#Область ДляВызоваИзДругихПодсистем

// СтандартныеПодсистемы.ВариантыОтчетов

// Настройки общей формы отчета подсистемы "Варианты отчетов".
//
// Параметры:
//   Форма - ФормаКлиентскогоПриложения, Неопределено - Форма отчета или форма настроек отчета.
//       Неопределено когда вызов без контекста.
//   КлючВарианта - Строка, Неопределено - Имя предопределенного
//       или уникальный идентификатор пользовательского варианта отчета.
//       Неопределено когда вызов без контекста.
//   Настройки - Структура - см. ОтчетыКлиентСервер.НастройкиОтчетаПоУмолчанию.
//
Процедура ОпределитьНастройкиФормы(Форма, КлючВарианта, Настройки) Экспорт
	Настройки.События.ПриСозданииНаСервере = Истина;
	Настройки.События.ПередЗагрузкойВариантаНаСервере = Истина;
	Настройки.События.ПередЗагрузкойНастроекВКомпоновщик = Истина;
	Настройки.События.ПриОпределенииПараметровВыбора = Истина;
	Настройки.События.ПриОпределенииСвойствЭлементовФормыНастроек = Истина;
	
	Настройки.РазрешеноЗагружатьСхему = Истина;
	Настройки.РазрешеноРедактироватьСхему = Истина;
	Настройки.РазрешеноВосстанавливатьСтандартнуюСхему = Истина;
	
	Настройки.ЗагрузитьНастройкиПриИзмененииПараметров = Отчеты.УниверсальныйОтчет.ЗагрузитьНастройкиПриИзмененииПараметров();
КонецПроцедуры

// См. ОтчетыПереопределяемый.ПриСозданииНаСервере.
Процедура ПриСозданииНаСервере(Форма, Отказ, СтандартнаяОбработка) Экспорт
	РазрешеноИзменятьВарианты = ОбщегоНазначенияКлиентСервер.СвойствоСтруктуры(
		Форма.НастройкиОтчета, "РазрешеноИзменятьВарианты", Ложь);
	
	Если РазрешеноИзменятьВарианты Тогда
		Форма.НастройкиОтчета.Вставить("ФормаНастроекРасширенныйРежим", 1);
	КонецЕсли;
КонецПроцедуры

// См. ОтчетыПереопределяемый.ПриОпределенииПараметровВыбора.
Процедура ПриОпределенииПараметровВыбора(Форма, СвойстваНастройки) Экспорт
	ДоступныеЗначения = ОбщегоНазначенияКлиентСервер.СвойствоСтруктуры(
		КомпоновщикНастроек.Настройки.ДополнительныеСвойства, "ДоступныеЗначения", Новый Структура);
	
	Попытка
		ЗначенияДляВыбора = ОбщегоНазначенияКлиентСервер.СвойствоСтруктуры(
			ДоступныеЗначения, СтрЗаменить(СвойстваНастройки.ПолеКД, "ПараметрыДанных.", ""));
	Исключение
		ЗначенияДляВыбора = Неопределено;
	КонецПопытки;
	
	Если ЗначенияДляВыбора <> Неопределено Тогда 
		СвойстваНастройки.ОграничиватьВыборУказаннымиЗначениями = Истина;
		СвойстваНастройки.ЗначенияДляВыбора = ЗначенияДляВыбора;
	КонецЕсли;
КонецПроцедуры

// Вызывается в обработчике одноименного события формы отчета после выполнения кода формы.
// См. "Расширение управляемой формы для отчета.ПередЗагрузкойВариантаНаСервере" в синтакс-помощнике.
//
// Параметры:
//   Форма - ФормаКлиентскогоПриложения - Форма отчета.
//   Настройки - НастройкиКомпоновкиДанных - Настройки для загрузки в компоновщик настроек.
//
Процедура ПередЗагрузкойВариантаНаСервере(Форма, Настройки) Экспорт
	ТекущийКлючСхемы = Неопределено;
	Схема = Неопределено;
	
	ЭтоЗагруженнаяСхема = Ложь;
	
	Если ТипЗнч(Настройки) = Тип("НастройкиКомпоновкиДанных") Или Настройки = Неопределено Тогда
		Если Настройки = Неопределено Тогда
			ДополнительныеСвойстваНастроек = КомпоновщикНастроек.Настройки.ДополнительныеСвойства;
		Иначе
			ДополнительныеСвойстваНастроек = Настройки.ДополнительныеСвойства;
		КонецЕсли;
		
		Если Форма.ТипФормыОтчета = ТипФормыОтчета.Основная
			И (Форма.РежимРасшифровки
			Или (Форма.КлючТекущегоВарианта <> "Main"
			И Форма.КлючТекущегоВарианта <> "Основной")) Тогда 
			
			ДополнительныеСвойстваНастроек.Вставить("ОтчетИнициализирован", Истина);
		КонецЕсли;
		
		ДвоичныеДанныеСхемы = ОбщегоНазначенияКлиентСервер.СвойствоСтруктуры(
			ДополнительныеСвойстваНастроек, "СхемаКомпоновкиДанных");
		
		Если ТипЗнч(ДвоичныеДанныеСхемы) = Тип("ДвоичныеДанные") Тогда
			ЭтоЗагруженнаяСхема = Истина;
			ТекущийКлючСхемы = ХешДвоичныхДанных(ДвоичныеДанныеСхемы);
			Схема = Отчеты.УниверсальныйОтчет.ИзвлечьСхемуИзДвоичныхДанных(ДвоичныеДанныеСхемы);
		КонецЕсли;
	КонецЕсли;
	
	Если ЭтоЗагруженнаяСхема Тогда
		КлючСхемы = ТекущийКлючСхемы;
		ОтчетыСервер.ПодключитьСхему(ЭтотОбъект, Форма, Схема, КлючСхемы);
	КонецЕсли;
КонецПроцедуры

// Вызывается перед загрузкой новых настроек. Используется для изменения схемы компоновки.
//   Например, если схема отчета зависит от ключа варианта или параметров отчета.
//   Чтобы изменения схемы вступили в силу следует вызывать метод ОтчетыСервер.ПодключитьСхему().
//
// Параметры:
//   Контекст - Произвольный - 
//       Параметры контекста, в котором используется отчет.
//       Используется для передачи в параметрах метода ОтчетыСервер.ПодключитьСхему().
//   КлючСхемы - Строка -
//       Идентификатор текущей схемы компоновщика настроек.
//       По умолчанию не заполнен (это означает что компоновщик инициализирован на основании основной схемы).
//       Используется для оптимизации, чтобы переинициализировать компоновщик как можно реже).
//       Может не использоваться если переинициализация выполняется безусловно.
//   КлючВарианта - Строка, Неопределено -
//       Имя предопределенного или уникальный идентификатор пользовательского варианта отчета.
//       Неопределено когда вызов для варианта расшифровки или без контекста.
//   Настройки - НастройкиКомпоновкиДанных, Неопределено -
//       Настройки варианта отчета, которые будут загружены в компоновщик настроек после его инициализации.
//       Неопределено когда настройки варианта не надо загружать (уже загружены ранее).
//   ПользовательскиеНастройки - ПользовательскиеНастройкиКомпоновкиДанных, Неопределено -
//       Пользовательские настройки, которые будут загружены в компоновщик настроек после его инициализации.
//       Неопределено когда пользовательские настройки не надо загружать (уже загружены ранее).
//
// Пример:
//  // Компоновщик отчета инициализируется на основании схемы из общих макетов:
//	Если КлючСхемы <> "1" Тогда
//		КлючСхемы = "1";
//		СхемаКД = ПолучитьОбщийМакет("МояОбщаяСхемаКомпоновки");
//		ОтчетыСервер.ПодключитьСхему(ЭтотОбъект, Контекст, СхемаКД, КлючСхемы);
//	КонецЕсли;
//
//  // Схема зависит от значения параметра, выведенного в пользовательские настройки отчета:
//	Если ТипЗнч(НовыеПользовательскиеНастройкиКД) = Тип("ПользовательскиеНастройкиКомпоновкиДанных") Тогда
//		ИмяОбъектаМетаданных = "";
//		Для Каждого ЭлементКД Из НовыеПользовательскиеНастройкиКД.Элементы Цикл
//			Если ТипЗнч(ЭлементКД) = Тип("ЗначениеПараметраНастроекКомпоновкиДанных") Тогда
//				ИмяПараметра = Строка(ЭлементКД.Параметр);
//				Если ИмяПараметра = "ОбъектМетаданных" Тогда
//					ИмяОбъектаМетаданных = ЭлементКД.Значение;
//				КонецЕсли;
//			КонецЕсли;
//		КонецЦикла;
//		Если КлючСхемы <> ИмяОбъектаМетаданных Тогда
//			КлючСхемы = ИмяОбъектаМетаданных;
//			СхемаКД = Новый СхемаКомпоновкиДанных;
//			// Наполнение схемы...
//			ОтчетыСервер.ПодключитьСхему(ЭтотОбъект, Контекст, СхемаКД, КлючСхемы);
//		КонецЕсли;
//	КонецЕсли;
//
Процедура ПередЗагрузкойНастроекВКомпоновщик(Контекст, КлючСхемы, КлючВарианта, Настройки, ПользовательскиеНастройки) Экспорт
	ТекущийКлючСхемы = Неопределено;
	
	Если Настройки = Неопределено Тогда 
		Настройки = КомпоновщикНастроек.Настройки;
	КонецЕсли;
	
	ЭтоЗагруженнаяСхема = Ложь;
	ДвоичныеДанныеСхемы = ОбщегоНазначенияКлиентСервер.СвойствоСтруктуры(
		Настройки.ДополнительныеСвойства, "СхемаКомпоновкиДанных");
	
	Если ТипЗнч(ДвоичныеДанныеСхемы) = Тип("ДвоичныеДанные") Тогда
		ТекущийКлючСхемы = ХешДвоичныхДанных(ДвоичныеДанныеСхемы);
		Если ТекущийКлючСхемы <> КлючСхемы Тогда
			Схема = Отчеты.УниверсальныйОтчет.ИзвлечьСхемуИзДвоичныхДанных(ДвоичныеДанныеСхемы);
			ЭтоЗагруженнаяСхема = Истина;
		КонецЕсли;
	КонецЕсли;
	
	ДоступныеЗначения = Неопределено;
	ФиксированныеПараметры = Отчеты.УниверсальныйОтчет.ФиксированныеПараметры(
		Настройки, ПользовательскиеНастройки, ДоступныеЗначения);
	
	Если ТекущийКлючСхемы = Неопределено Тогда 
		ТекущийКлючСхемы = ФиксированныеПараметры.ТипОбъектаМетаданных
			+ "/" + ФиксированныеПараметры.ИмяОбъектаМетаданных
			+ "/" + ФиксированныеПараметры.ИмяТаблицы;
		ТекущийКлючСхемы = ОбщегоНазначения.СократитьСтрокуКонтрольнойСуммой(ТекущийКлючСхемы, 100);
		
		Если ТекущийКлючСхемы <> КлючСхемы Тогда
			КлючСхемы = "";
			Схема = Отчеты.УниверсальныйОтчет.СхемаКомпоновкиДанных(ФиксированныеПараметры);
		КонецЕсли;
	КонецЕсли;
	
	Если ТекущийКлючСхемы <> Неопределено И ТекущийКлючСхемы <> КлючСхемы Тогда
		КлючСхемы = ТекущийКлючСхемы;
		ОтчетыСервер.ПодключитьСхему(ЭтотОбъект, Контекст, Схема, КлючСхемы);
		
		Если ЭтоЗагруженнаяСхема Тогда
			Отчеты.УниверсальныйОтчет.УстановитьСтандартныеНастройкиЗагруженнойСхемы(
				ЭтотОбъект, ДвоичныеДанныеСхемы, Настройки, ПользовательскиеНастройки);
		Иначе
			Отчеты.УниверсальныйОтчет.УстановитьСтандартныеНастройки(
				ЭтотОбъект, ФиксированныеПараметры, Настройки, ПользовательскиеНастройки);
		КонецЕсли;
		
		Если ТипЗнч(Контекст) = Тип("ФормаКлиентскогоПриложения") Тогда
			// Переопределение.
			ИнтеграцияПодсистемБСП.ПередЗагрузкойВариантаНаСервере(Контекст, Настройки);
			ОтчетыПереопределяемый.ПередЗагрузкойВариантаНаСервере(Контекст, Настройки);
			ПередЗагрузкойВариантаНаСервере(Контекст, Настройки);
		КонецЕсли;
	Иначе
		Отчеты.УниверсальныйОтчет.УстановитьФиксированныеПараметры(
			ЭтотОбъект, ФиксированныеПараметры, Настройки, ПользовательскиеНастройки);
	КонецЕсли;
	
	КомпоновщикНастроек.Настройки.ДополнительныеСвойства.Вставить("ДоступныеЗначения", ДоступныеЗначения);
КонецПроцедуры

// Вызывается после определения свойств элементов формы, связанных с пользовательскими настройками.
// См. ОтчетыСервер.СвойстваЭлементовФормыНастроек()
// Позволяет переопределить свойства, для целей персонализации отчета.
//
// Параметры:
//  ТипФормы - ТипФормыОтчета - см. Синтакс-помощник.
//  СвойстваЭлементов - Структура - см. ОтчетыСервер.СвойстваЭлементовФормыНастроек().
//  ПользовательскиеНастройки - КоллекцияЭлементовПользовательскихНастроекКомпоновкиДанных - элементы актуальных
//                              пользовательских настроек, влияющих на создание связанных элементов формы.
//
Процедура ПриОпределенииСвойствЭлементовФормыНастроек(ТипФормы, СвойстваЭлементов, ПользовательскиеНастройки) Экспорт 
	Если ТипФормы <> ТипФормыОтчета.Основная Тогда 
		Возврат;
	КонецЕсли;
	
	СвойстваГруппы = ОтчетыСервер.СвойстваГруппыЭлементовФормы();
	СвойстваГруппы.Группировка = ГруппировкаПодчиненныхЭлементовФормы.ГоризонтальнаяВсегда;
	СвойстваЭлементов.Группы.Вставить("ФиксированныеПараметры", СвойстваГруппы);
	
	ФиксированныеПараметры = Новый Структура("Период, ТипОбъектаМетаданных, ИмяОбъектаМетаданных, ИмяТаблицы");
	ШиринаПоля = Новый Структура("ТипОбъектаМетаданных, ИмяОбъектаМетаданных, ИмяТаблицы", 20, 35, 20);
	
	Для Каждого ЭлементНастройки Из ПользовательскиеНастройки Цикл 
		Если ТипЗнч(ЭлементНастройки) <> Тип("ЗначениеПараметраНастроекКомпоновкиДанных")
			Или Не ФиксированныеПараметры.Свойство(ЭлементНастройки.Параметр) Тогда 
			Продолжить;
		КонецЕсли;
		
		СвойстваПоля = СвойстваЭлементов.Поля.Найти(
			ЭлементНастройки.ИдентификаторПользовательскойНастройки, "ИдентификаторНастройки");
		
		Если СвойстваПоля = Неопределено Тогда 
			Продолжить;
		КонецЕсли;
		
		СвойстваПоля.ИдентификаторГруппы = "ФиксированныеПараметры";
		
		ИмяПараметра = Строка(ЭлементНастройки.Параметр);
		Если ИмяПараметра <> "Период" Тогда 
			СвойстваПоля.ПоложениеЗаголовка = ПоложениеЗаголовкаЭлементаФормы.Нет;
			СвойстваПоля.Ширина = ШиринаПоля[ИмяПараметра];
			СвойстваПоля.РастягиватьПоГоризонтали = Ложь;
		КонецЕсли;
	КонецЦикла;
КонецПроцедуры

// Конец СтандартныеПодсистемы.ВариантыОтчетов

#КонецОбласти

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Возвращает хеш-сумму двоичных данных.
//
// Параметры:
//   ДвоичныеДанные - ДвоичныеДанные - Данные, от которых считается хеш-сумма.
//
Функция ХешДвоичныхДанных(ДвоичныеДанные)
	ХешированиеДанных = Новый ХешированиеДанных(ХешФункция.MD5);
	ХешированиеДанных.Добавить(ДвоичныеДанные);
	Возврат СтрЗаменить(ХешированиеДанных.ХешСумма, " ", "") + "_" + Формат(ДвоичныеДанные.Размер(), "ЧГ=");
КонецФункции

#КонецОбласти

#Иначе
ВызватьИсключение НСтр("ru = 'Недопустимый вызов объекта на клиенте.'");
#КонецЕсли