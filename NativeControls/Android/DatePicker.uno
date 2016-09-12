using Uno;
using Uno.Time;
using Uno.Compiler.ExportTargetInterop;

using Fuse;
using Fuse.Controls;
using Fuse.Controls.Native;

namespace Native.Android
{
	extern(Android) class DatePicker : 
		Fuse.Controls.Native.Android.LeafView,
		IDatePickerView
	{

		IDatePickerHost _host;

		public DatePicker(IDatePickerHost host) : base(Create())
		{
			_host = host;
			Init(Handle, OnDateChanged);
		}

		public override void Dispose()
		{
			base.Dispose();
			_host = null;
		}

		// Month starts at 0 in Java
		// https://developer.android.com/reference/java/util/Calendar.html#MONTH

		public LocalDate CurrentDate
		{
			get
			{
				var date = new int[3];
				GetDate(Handle, date);
				var year = date[0];
				var month = date[1] + 1;
				var day = date[2];
				return new LocalDate(year, month, day);
			}
		}
		
		void IDatePickerView.SetDate(LocalDate date)
		{
			SetDate(Handle, date.Year, date.Month - 1, date.Day);
		}

		void IDatePickerView.SetMinDate(LocalDate date)
		{
			SetMinDate(Handle, date.Year, date.Month - 1, date.Day);
		}

		void IDatePickerView.SetMaxDate(LocalDate date)
		{
			SetMaxDate(Handle, date.Year, date.Month - 1, date.Day);
		}

		void OnDateChanged()
		{
			_host.OnDateChanged(CurrentDate);
		}

		[Foreign(Language.Java)]
		static Java.Object Create()
		@{
			return new android.widget.DatePicker(@(Activity.Package).@(Activity.Name).GetRootActivity());
		@}

		[Foreign(Language.Java)]
		void Init(Java.Object datePickerHandle, Action onDateChangedCallback)
		@{
			android.widget.DatePicker datePicker = (android.widget.DatePicker)datePickerHandle;
			java.util.Calendar c = java.util.Calendar.getInstance();

			int y = c.get(java.util.Calendar.YEAR);
			int m = c.get(java.util.Calendar.MONTH);
			int d = c.get(java.util.Calendar.DAY_OF_MONTH);

			datePicker.init(y, m, d, new android.widget.DatePicker.OnDateChangedListener() {

				public void onDateChanged(android.widget.DatePicker view, int year, int month, int day) {
					onDateChangedCallback.run();
				}

			});
		@}

		[Foreign(Language.Java)]
		void SetDate(Java.Object datePickerHandle, int year, int month, int day)
		@{
			android.widget.DatePicker datePicker = (android.widget.DatePicker)datePickerHandle;
			datePicker.updateDate(year, month, day);
		@}

		[Foreign(Language.Java)]
		void SetMinDate(Java.Object datePickerHandle, int year, int month, int day)
		@{
			android.widget.DatePicker datePicker = (android.widget.DatePicker)datePickerHandle;
			datePicker.setMinDate(new java.util.Date(year, month, day).getTime());
		@}

		[Foreign(Language.Java)]
		void SetMaxDate(Java.Object datePickerHandle, int year, int month, int day)
		@{
			android.widget.DatePicker datePicker = (android.widget.DatePicker)datePickerHandle;
			datePicker.setMaxDate(new java.util.Date(year, month, day).getTime());
		@}

		[Foreign(Language.Java)]
		void GetDate(Java.Object datePickerHandle, int[] x)
		@{
			android.widget.DatePicker datePicker = (android.widget.DatePicker)datePickerHandle;
			x.set(0, datePicker.getYear());
			x.set(1, datePicker.getMonth());
			x.set(2, datePicker.getDayOfMonth());
		@}

	}
}
