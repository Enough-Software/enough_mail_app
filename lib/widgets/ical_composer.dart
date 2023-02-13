import 'package:enough_icalendar/enough_icalendar.dart';
import 'package:enough_mail_app/models/account.dart';
import 'package:enough_mail_app/services/i18n_service.dart';
import 'package:enough_mail_app/services/mail_service.dart';
import 'package:enough_mail_app/util/modal_bottom_sheet_helper.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/material.dart';
import 'package:enough_mail_app/util/datetime.dart';
import '../locator.dart';
import '../l10n/app_localizations.g.dart';

class IcalComposer extends StatefulWidget {
  const IcalComposer({Key? key, required this.appointment}) : super(key: key);
  final VCalendar appointment;
  @override
  State<IcalComposer> createState() => _IcalComposerState();

  static Future<VCalendar?> createOrEditAppointment(BuildContext context,
      {VCalendar? appointment}) async {
    final localizations = AppLocalizations.of(context);
    // final iconService = locator<IconService>();
    var account = locator<MailService>().currentAccount!;
    if (account.isVirtual) {
      account = locator<MailService>().accounts.first;
    }
    if (account is! RealAccount) {
      return null;
    }
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day, (now.hour + 1) % 24);
    final end = DateTime(start.year, start.month, start.day, start.hour, 30);
    final editAppointment = appointment ??
        VCalendar.createEvent(
          start: start,
          end: end,
          organizerEmail: account.email,
        );
    final result = await ModelBottomSheetHelper.showModalBottomSheet(
      context,
      editAppointment.summary ?? localizations.composeAppointmentTitle,
      IcalComposer(appointment: editAppointment),
    );

    if (result) {
      _IcalComposerState._current.apply();
      appointment = editAppointment;
    }
    return appointment;
  }
}

class _IcalComposerState extends State<IcalComposer> {
  static late _IcalComposerState _current;
  final TextEditingController _summaryController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  // final List<MailAddress> _participants = <MailAddress>[];
  // late MailAccount _organizerAccount;
  late VEvent _event;
  DateTime? _previousStart;
  DateTime? _previousEnd;

  @override
  void initState() {
    _current = this;
    super.initState();
    final ev = widget.appointment.event;
    if (ev != null) {
      _event = ev;
      _summaryController.text = ev.summary ?? '';
      _descriptionController.text = ev.description ?? '';
      _locationController.text = ev.location ?? '';
    } else {
      _event = VEvent(parent: widget.appointment);
      widget.appointment.children.add(_event);
    }
  }

  @override
  void dispose() {
    apply();
    _summaryController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void apply() {
    final ev = _event;
    ev.summary = _summaryController.text;
    ev.description = _descriptionController.text.isNotEmpty
        ? _descriptionController.text
        : null;
    ev.location =
        _locationController.text.isNotEmpty ? _locationController.text : null;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    // final i18nService = locator<I18nService>();
    final end = _event.end;
    final start = _event.start!;
    final isAllday = _event.isAllDayEvent ?? false;
    final recurrenceRule = _event.recurrenceRule;
    final theme = Theme.of(context);
    return Material(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            DecoratedPlatformTextField(
              controller: _summaryController,
              decoration: InputDecoration(
                labelText: localizations.icalendarLabelSummary,
              ),
              cupertinoAlignLabelOnTop: true,
            ),
            DecoratedPlatformTextField(
              controller: _descriptionController,
              keyboardType: TextInputType.multiline,
              minLines: 3,
              maxLines: 8,
              decoration: InputDecoration(
                labelText: localizations.icalendarLabelDescription,
              ),
              cupertinoAlignLabelOnTop: true,
            ),
            DecoratedPlatformTextField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: localizations.icalendarLabelLocation,
              ),
              cupertinoAlignLabelOnTop: true,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 0.0),
              child: Text(localizations.icalendarLabelStart,
                  style: theme.textTheme.caption),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: DateTimePicker(
                dateTime: start,
                onlyDate: isAllday,
                onChanged: (dateTime) {
                  if (end != null) {
                    final diff = end.difference(start);
                    _event.end = dateTime.add(diff);
                  }
                  setState(() {
                    _event.start = dateTime;
                  });
                },
              ),
            ),
            if (!isAllday) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 0.0),
                child: Text(localizations.icalendarLabelEnd,
                    style: theme.textTheme.caption),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: DateTimePicker(
                  dateTime: end,
                  onChanged: (dateTime) {
                    setState(() {
                      _event.end = dateTime;
                    });
                  },
                ),
              ),
            ],
            PlatformCheckboxListTile(
              value: isAllday,
              title: Text(localizations.composeAppointmentLabelAllDayEvent),
              onChanged: (value) {
                if (value == null || value == false) {
                  _event.duration = null;
                  _event.start = _previousStart;
                  _event.end = _previousEnd;
                } else {
                  _previousStart = start;
                  _previousEnd = end;
                  _event.end = null;
                  _event.start = DateTime(start.year, start.month, start.day);
                  _event.duration = IsoDuration(days: 1);
                }
                setState(() {
                  _event.isAllDayEvent = value;
                });
              },
            ),
            const Divider(),
            PlatformListTile(
              title: Text(localizations.composeAppointmentLabelRepeat),
              trailing: recurrenceRule == null
                  ? Text(localizations.composeAppointmentLabelRepeatOptionNever)
                  : null,
              subtitle: recurrenceRule == null
                  ? null
                  : Text(
                      recurrenceRule.toHumanReadableText(
                        languageCode: localizations.localeName,
                        startDate: start,
                      ),
                      style: theme.textTheme.caption,
                    ),
              onTap: () async {
                final result = await RecurrenceComposer.createOrEditRecurrence(
                    context, recurrenceRule, start);
                setState(() {
                  _event.recurrenceRule = result;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

enum _RepeatFrequency { never, daily, weekly, monthly, yearly }

extension _ExtensionRepeatFrequency on _RepeatFrequency {
  RecurrenceFrequency? get recurrenceFrequency {
    switch (this) {
      case _RepeatFrequency.never:
        return null;
      case _RepeatFrequency.daily:
        return RecurrenceFrequency.daily;
      case _RepeatFrequency.weekly:
        return RecurrenceFrequency.weekly;
      case _RepeatFrequency.monthly:
        return RecurrenceFrequency.monthly;
      case _RepeatFrequency.yearly:
        return RecurrenceFrequency.yearly;
    }
  }

  String localization(AppLocalizations localizations) {
    switch (this) {
      case _RepeatFrequency.never:
        return localizations.composeAppointmentLabelRepeatOptionNever;
      case _RepeatFrequency.daily:
        return localizations.composeAppointmentLabelRepeatOptionDaily;
      case _RepeatFrequency.weekly:
        return localizations.composeAppointmentLabelRepeatOptionWeekly;
      case _RepeatFrequency.monthly:
        return localizations.composeAppointmentLabelRepeatOptionMonthly;
      case _RepeatFrequency.yearly:
        return localizations.composeAppointmentLabelRepeatOptionYearly;
    }
  }
}

extension _ExtensionRecurrenceFrequency on RecurrenceFrequency {
  _RepeatFrequency get repeatFrequency {
    switch (this) {
      case RecurrenceFrequency.secondly:
      case RecurrenceFrequency.minutely:
      case RecurrenceFrequency.hourly:
      case RecurrenceFrequency.daily:
        return _RepeatFrequency.daily;
      case RecurrenceFrequency.weekly:
        return _RepeatFrequency.weekly;
      case RecurrenceFrequency.monthly:
        return _RepeatFrequency.monthly;
      case RecurrenceFrequency.yearly:
        return _RepeatFrequency.yearly;
    }
  }

  IsoDuration? get recommendedUntil {
    switch (this) {
      case RecurrenceFrequency.secondly:
      case RecurrenceFrequency.minutely:
      case RecurrenceFrequency.hourly:
        return null;
      case RecurrenceFrequency.daily:
        return IsoDuration(months: 3);
      case RecurrenceFrequency.weekly:
        return IsoDuration(months: 6);
      case RecurrenceFrequency.monthly:
        return IsoDuration(years: 1);
      case RecurrenceFrequency.yearly:
        return null;
    }
  }
}

class DateTimePicker extends StatelessWidget {
  final DateTime? dateTime;
  final void Function(DateTime newDateTime) onChanged;
  final bool onlyDate;
  const DateTimePicker({
    Key? key,
    required this.dateTime,
    required this.onChanged,
    this.onlyDate = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final i18nService = locator<I18nService>();
    final localizations = AppLocalizations.of(context)!;
    final dt = dateTime;
    return Row(
      children: [
        // set date button:
        PlatformTextButton(
          child: PlatformText(
            dt == null
                ? localizations.composeAppointmentLabelDay
                : i18nService.formatDate(dt.toLocal(), useLongFormat: true),
          ),
          onPressed: () async {
            FocusScope.of(context).unfocus();
            final initialDate = dt ?? DateTime.now();
            final firstDate = DateTime.now();
            final lastDate =
                DateTime(firstDate.year + 10, firstDate.month, firstDate.day);
            final newStartDate = await showPlatformDatePicker(
              context: context,
              initialDate: initialDate,
              firstDate: firstDate,
              lastDate: lastDate,
            );
            if (newStartDate != null) {
              final withTimeOfDay =
                  newStartDate.withTimeOfDay(initialDate.toTimeOfDay());
              onChanged(withTimeOfDay);
            }
          },
        ),
        if (!onlyDate)
          // set time button:
          PlatformTextButton(
            child: PlatformText(
              dt == null
                  ? localizations.composeAppointmentLabelTime
                  : i18nService.formatTimeOfDay(
                      TimeOfDay.fromDateTime(dt.toLocal()), context),
            ),
            onPressed: () async {
              FocusScope.of(context).unfocus();
              final initialDateTime = dt ?? DateTime.now();
              final initialTime = initialDateTime.toTimeOfDay();
              final newStartTime = await showPlatformTimePicker(
                context: context,
                initialTime: initialTime,
              );

              if (newStartTime != null) {
                final withTimeOfDay =
                    initialDateTime.withTimeOfDay(newStartTime);
                onChanged(withTimeOfDay);
              }
            },
          ),
      ],
    );
  }
}

class RecurrenceComposer extends StatefulWidget {
  final Recurrence? recurrenceRule;
  final DateTime startDate;
  const RecurrenceComposer(
      {Key? key, this.recurrenceRule, required this.startDate})
      : super(key: key);

  @override
  State<RecurrenceComposer> createState() => _RecurrenceComposerState();

  static Future<Recurrence?> createOrEditRecurrence(BuildContext context,
      Recurrence? recurrenceRule, DateTime startDate) async {
    final localizations = AppLocalizations.of(context)!;
    // final iconService = locator<IconService>();

    final result = await ModelBottomSheetHelper.showModalBottomSheet(
      context,
      localizations.composeAppointmentLabelRepeat,
      RecurrenceComposer(
        recurrenceRule: recurrenceRule,
        startDate: startDate,
      ),
    );

    if (result) {
      return _RecurrenceComposerState._currentState._recurrenceRule;
    } else {
      return recurrenceRule;
    }
  }
}

class _RecurrenceComposerState extends State<RecurrenceComposer> {
  static late _RecurrenceComposerState _currentState;
  Recurrence? _recurrenceRule;
  _RepeatFrequency _repeatFrequency = _RepeatFrequency.never;
  DateTime? _recommendationDate;

  @override
  void initState() {
    _currentState = this;
    super.initState();
    final rule = widget.recurrenceRule;
    _recurrenceRule = rule;
    if (rule != null) {
      _repeatFrequency = rule.frequency.repeatFrequency;
    }
  }

  @override
  Widget build(BuildContext context) {
    final i18nService = locator<I18nService>();
    final localizations = AppLocalizations.of(context)!;
    final rule = _recurrenceRule;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                    localizations.composeAppointmentRecurrenceFrequencyLabel),
              ),
              PlatformDropdownButton<_RepeatFrequency>(
                items: _RepeatFrequency.values
                    .map((rf) => DropdownMenuItem<_RepeatFrequency>(
                          value: rf,
                          child: Text(rf.localization(localizations)),
                        ))
                    .toList(),
                onChanged: (freq) {
                  if (freq == null || freq == _RepeatFrequency.never) {
                    setState(() {
                      _repeatFrequency = _RepeatFrequency.never;
                      _recurrenceRule = null;
                    });
                    return;
                  }
                  DateTime? until;
                  final duration = freq.recurrenceFrequency!.recommendedUntil;
                  if (duration == null) {
                    _recommendationDate = null;
                  } else {
                    until = duration.addTo(widget.startDate);
                    _recommendationDate = until;
                  }
                  var newRule = (rule != null)
                      ? rule.copyWith(
                          frequency: freq.recurrenceFrequency,
                          until: until,
                          copyByRules: false,
                          copyUntil: false,
                        )
                      : Recurrence(
                          freq.recurrenceFrequency!,
                          until: until,
                        );
                  if (newRule.frequency == RecurrenceFrequency.monthly) {
                    final monthly = DayOfMonthSelector.updateMonthlyRecurrence(
                        newRule, widget.startDate);
                    if (monthly != null) {
                      newRule = monthly;
                    }
                  }
                  setState(() {
                    _repeatFrequency = freq;
                    _recurrenceRule = newRule;
                  });
                },
                value: _repeatFrequency,
              ),
            ],
          ),
          if (rule != null) ...[
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                      localizations.composeAppointmentRecurrenceIntervalLabel),
                ),
                PlatformDropdownButton<int>(
                  items: List.generate(
                    10,
                    (index) => DropdownMenuItem<int>(
                      value: index + 1,
                      child: Text('${index + 1}'),
                    ),
                  ),
                  onChanged: (interval) {
                    setState(() {
                      _recurrenceRule = rule.copyWith(interval: interval);
                    });
                  },
                  value: rule.interval,
                ),
              ],
            ),
            if (rule.frequency == RecurrenceFrequency.weekly) ...[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child:
                    Text(localizations.composeAppointmentRecurrenceDaysLabel),
              ),
              WeekDaySelector(
                recurrence: rule,
                startDate: widget.startDate,
                onChanged: (rules) {
                  Recurrence value;
                  if (rules == null) {
                    value = rule.copyWith(copyByRules: false);
                  } else {
                    value = rule.copyWith(byWeekDay: rules);
                  }
                  setState(() {
                    _recurrenceRule = value;
                  });
                },
              ),
            ] else if (rule.frequency == RecurrenceFrequency.monthly) ...[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child:
                    Text(localizations.composeAppointmentRecurrenceDaysLabel),
              ),
              DayOfMonthSelector(
                recurrence: rule,
                startDate: widget.startDate,
                onChanged: (value) {
                  setState(() {
                    _recurrenceRule = value;
                  });
                },
              ),
            ],
            PlatformListTile(
              title: Text(localizations.composeAppointmentRecurrenceUntilLabel),
              trailing: Text(rule.until == null
                  ? localizations
                      .composeAppointmentRecurrenceUntilOptionUnlimited
                  : rule.until == _recommendationDate
                      ? localizations
                          .composeAppointmentRecurrenceUntilOptionRecommended(
                              i18nService.formatIsoDuration(
                                  rule.frequency.recommendedUntil!))
                      : i18nService.formatDate(rule.until,
                          useLongFormat: true)),
              onTap: () async {
                final until = await UntilComposer.createOrEditUntil(
                  context,
                  widget.startDate,
                  rule.until,
                  rule.frequency.recommendedUntil,
                );
                final newRule = (until == null)
                    ? rule.copyWithout(RecurrenceAttribute.until)
                    : rule.copyWith(until: until);
                setState(() {
                  _recurrenceRule = newRule;
                });
              },
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(rule.toHumanReadableText(
                languageCode: localizations.localeName,
                startDate: widget.startDate,
              )),
            ),
          ],
        ],
      ),
    );
  }
}

class WeekDaySelector extends StatefulWidget {
  final Recurrence recurrence;
  final DateTime startDate;
  final void Function(List<ByDayRule>? rules) onChanged;
  const WeekDaySelector({
    Key? key,
    required this.recurrence,
    required this.onChanged,
    required this.startDate,
  }) : super(key: key);

  @override
  State<WeekDaySelector> createState() => _WeekDaySelectorState();
}

class _WeekDaySelectorState extends State<WeekDaySelector> {
  late List<WeekDay> _weekdays;
  final _selectedDays = <bool>[false, false, false, false, false, false, false];
  @override
  void initState() {
    super.initState();
    final i18nService = locator<I18nService>();
    _weekdays = i18nService.formatWeekDays(abbreviate: true);
    final byWeekDays = widget.recurrence.byWeekDay;
    if (byWeekDays != null) {
      int firstDayOfWeek = i18nService.firstDayOfWeek;
      for (int i = 0; i < 7; i++) {
        final day = ((firstDayOfWeek + i) <= 7)
            ? (firstDayOfWeek + i)
            : ((firstDayOfWeek + i) - 7);
        bool isSelected = byWeekDays.any((dayRule) => dayRule.weekday == day);
        _selectedDays[i] = isSelected;
      }
    }
    _selectStartDateWeekDay();
  }

  void _selectStartDateWeekDay() {
    final startDateWeekDay = widget.startDate.weekday;
    final index =
        _weekdays.indexWhere((weekDay) => weekDay.day == startDateWeekDay);
    _selectedDays[index] = true;
  }

  void _toggle(int index) {
    final day = _weekdays[index].day;
    var isSelected = !_selectedDays[index];
    var rules = widget.recurrence.byWeekDay;
    if (isSelected) {
      if (rules == null) {
        rules = [ByDayRule(day), ByDayRule(widget.startDate.weekday)];
      } else {
        rules.add(ByDayRule(day));
      }
    } else {
      if (rules != null) {
        rules.removeWhere((rule) => rule.weekday == day);
        if (rules.isEmpty ||
            rules.length == 1 && rules[0].weekday == widget.startDate.weekday) {
          rules = null;
          // re-select weekday from start day:
          _selectStartDateWeekDay();
        }
      } else if (day == widget.startDate.weekday) {
        isSelected = true;
      }
    }
    widget.onChanged(rules);
    setState(() => _selectedDays[index] = isSelected);
  }

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: PlatformToggleButtons(
        isSelected: _selectedDays,
        onPressed: _toggle,
        children: _weekdays
            .map((day) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(day.name),
                ))
            .toList(),
      ),
    );
  }
}

enum _DayOfMonthOption { dayOfMonth, dayInNumberedWeek }

class DayOfMonthSelector extends StatefulWidget {
  final Recurrence recurrence;
  final DateTime startDate;
  final void Function(Recurrence recurrence) onChanged;
  const DayOfMonthSelector(
      {Key? key,
      required this.recurrence,
      required this.startDate,
      required this.onChanged})
      : super(key: key);

  @override
  State<DayOfMonthSelector> createState() => _DayOfMonthSelectorState();

  static Recurrence? updateMonthlyRecurrence(
      Recurrence recurrence, DateTime startDate) {
    if (recurrence.hasByMonthDay || recurrence.hasByWeekDay) {
      return null;
    }
    final day = startDate.day;
    final weekday = startDate.weekday;
    var week = (day / 7).ceil();
    if (week > 3) {
      // is the last or the second last weekday?
      final daysInMonth = DateTime(startDate.year, startDate.month + 1, 0).day;
      week = -((daysInMonth - day) / 7).ceil();
    }
    final rule = ByDayRule(weekday, week: week);
    return recurrence.copyWith(byWeekDay: [rule], copyByRules: false);
  }
}

class _DayOfMonthSelectorState extends State<DayOfMonthSelector> {
  late _DayOfMonthOption _option;
  ByDayRule? _byDayRule;
  WeekDay? _currentWeekday;
  late List<WeekDay> _weekdays;

  @override
  void initState() {
    super.initState();
    _weekdays = locator<I18nService>().formatWeekDays();
    if (widget.recurrence.hasByMonthDay) {
      _option = _DayOfMonthOption.dayOfMonth;
    } else {
      var recurrence = widget.recurrence;
      if (!widget.recurrence.hasByWeekDay) {
        recurrence = DayOfMonthSelector.updateMonthlyRecurrence(
                recurrence, widget.startDate) ??
            recurrence;
      }
      _option = _DayOfMonthOption.dayInNumberedWeek;
      final rule = recurrence.byWeekDay!.first;
      _byDayRule = rule;
      _currentWeekday = _weekdays.firstWhere((wd) => wd.day == rule.weekday);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final rule = _byDayRule;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PlatformRadioListTile<_DayOfMonthOption>(
          groupValue: _option,
          value: _DayOfMonthOption.dayOfMonth,
          title: Text(
              localizations.composeAppointmentRecurrenceMonthlyOnDayOfMonth(
                  widget.startDate.day)),
          onChanged: (value) {
            setState(() {
              _option = value!;
            });
            widget.onChanged(widget.recurrence.copyWith(
                byMonthDay: [widget.startDate.day], copyByRules: false));
          },
        ),
        PlatformRadioListTile<_DayOfMonthOption>(
          groupValue: _option,
          value: _DayOfMonthOption.dayInNumberedWeek,
          title:
              Text(localizations.composeAppointmentRecurrenceMonthlyOnWeekDay),
          onChanged: (value) {
            if (_byDayRule == null) {
              final recurrence = DayOfMonthSelector.updateMonthlyRecurrence(
                  widget.recurrence.copyWith(copyByRules: false),
                  widget.startDate)!;
              final rule = recurrence.byWeekDay!.first;
              _byDayRule = rule;
              _currentWeekday =
                  _weekdays.firstWhere((wd) => wd.day == rule.weekday);
              widget.onChanged(recurrence);
            }
            setState(() {
              _option = value!;
            });
          },
        ),
        if (_option == _DayOfMonthOption.dayInNumberedWeek && rule != null) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(32.0, 8.0, 8.0, 32.0),
            child: Row(
              children: [
                PlatformDropdownButton<int>(
                  items: [
                    DropdownMenuItem<int>(
                      value: 1,
                      child:
                          Text(localizations.composeAppointmentRecurrenceFirst),
                    ),
                    DropdownMenuItem<int>(
                      value: 2,
                      child: Text(
                          localizations.composeAppointmentRecurrenceSecond),
                    ),
                    DropdownMenuItem<int>(
                      value: 3,
                      child:
                          Text(localizations.composeAppointmentRecurrenceThird),
                    ),
                    DropdownMenuItem<int>(
                      value: -1,
                      child:
                          Text(localizations.composeAppointmentRecurrenceLast),
                    ),
                    DropdownMenuItem<int>(
                      value: -2,
                      child: Text(
                          localizations.composeAppointmentRecurrenceSecondLast),
                    ),
                  ],
                  value: rule.week,
                  onChanged: (value) {
                    final newRule = ByDayRule(rule.weekday, week: value);
                    _byDayRule = newRule;
                    final recurrence =
                        widget.recurrence.copyWith(byWeekDay: [newRule]);
                    widget.onChanged(recurrence);
                  },
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                ),
                PlatformDropdownButton<WeekDay>(
                  items: _weekdays
                      .map((wd) => DropdownMenuItem<WeekDay>(
                            value: wd,
                            child: Text(wd.name),
                          ))
                      .toList(),
                  value: _currentWeekday,
                  onChanged: (value) {
                    final newRule = ByDayRule(value!.day, week: rule.week);
                    _byDayRule = newRule;
                    final recurrence =
                        widget.recurrence.copyWith(byWeekDay: [newRule]);
                    widget.onChanged(recurrence);
                  },
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class UntilComposer extends StatefulWidget {
  final DateTime start;
  final DateTime? until;
  final IsoDuration? recommendation;
  const UntilComposer(
      {Key? key, required this.start, this.until, this.recommendation})
      : super(key: key);

  @override
  State<UntilComposer> createState() => _UntilComposerState();

  static Future<DateTime?> createOrEditUntil(BuildContext context,
      DateTime start, DateTime? until, IsoDuration? recommendation) async {
    final localizations = AppLocalizations.of(context)!;
    // final iconService = locator<IconService>();
    final result = await ModelBottomSheetHelper.showModalBottomSheet(
      context,
      localizations.composeAppointmentRecurrenceUntilLabel,
      UntilComposer(start: start, until: until, recommendation: recommendation),
    );

    if (result) {
      return _UntilComposerState._currentState._until;
    } else {
      return until;
    }
  }
}

class _UntilComposerState extends State<UntilComposer> {
  static late _UntilComposerState _currentState;
  late _UntilOption _option;
  DateTime? _recommendationDate;
  DateTime? _until;

  @override
  void initState() {
    super.initState();
    _currentState = this;
    _until = widget.until;
    final recommendation = widget.recommendation;
    if (recommendation != null) {
      _recommendationDate = recommendation.addTo(widget.start);
    }
    if (_until == null) {
      _option = _UntilOption.unlimited;
    } else if (_until == _recommendationDate) {
      _option = _UntilOption.recommendation;
    } else {
      _option = _UntilOption.date;
    }
  }

  @override
  Widget build(BuildContext context) {
    // final i18nService = locator<I18nService>();
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final value in _UntilOption.values)
            if (_recommendationDate != null ||
                value != _UntilOption.recommendation)
              PlatformRadioListTile<_UntilOption>(
                groupValue: _option,
                value: value,
                onChanged: _onChanged,
                title: Text(
                    value.localization(localizations, widget.recommendation)),
              ),
          if (_option == _UntilOption.date) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 0.0),
              child: Text(localizations.composeAppointmentRecurrenceUntilLabel,
                  style: theme.textTheme.caption),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: DateTimePicker(
                dateTime: _until,
                onlyDate: true,
                onChanged: (dateTime) {
                  setState(() {
                    _until = dateTime;
                  });
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _onChanged(_UntilOption? value) {
    if (value != null) {
      switch (value) {
        case _UntilOption.unlimited:
          _until = null;
          break;
        case _UntilOption.recommendation:
          _until = _recommendationDate;
          break;
        case _UntilOption.date:
          break;
      }
      setState(() {
        _option = value;
      });
    }
  }
}

enum _UntilOption { unlimited, recommendation, date }

extension _ExtensionUntilOption on _UntilOption {
  String localization(
      AppLocalizations localizations, IsoDuration? recommendation) {
    switch (this) {
      case _UntilOption.unlimited:
        return localizations.composeAppointmentRecurrenceUntilOptionUnlimited;
      case _UntilOption.recommendation:
        final duration = recommendation == null
            ? ''
            : locator<I18nService>().formatIsoDuration(recommendation);
        return localizations
            .composeAppointmentRecurrenceUntilOptionRecommended(duration);
      case _UntilOption.date:
        return localizations
            .composeAppointmentRecurrenceUntilOptionSpecificDate;
    }
  }
}
