jQuery ->
  $("a[rel~=popover], .has-popover").popover()
  $("a[rel~=tooltip], .has-tooltip").tooltip()
  $(".date-field").each (index, elem) ->
    e = $(elem)
    e.datepicker(e.data())
