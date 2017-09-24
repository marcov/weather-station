
function createDaySelect(name) {
    var htmlCode = "";
    htmlCode += "<select name=" + name + " size='1'>";
	var mydate = new Date();
	var myday = mydate.getDate();
	var daystring = "";
  
	
	for (var i = 1; i <= 31; ++i) {
		if(i<10) {
			daystring = "0" + i;
			htmlCode += daystring;
		} else {
			daystring = i;
			htmlCode += daystring;
		}
		
        if (myday == daystring) {
			htmlCode += "option selected='selected' value='" + daystring + "'>" + daystring + "</option>";
		} else {
			htmlCode += "<option value='" + daystring + "'>" + daystring + "</option>";
		}
	}
	htmlCode += "</select>";
  
    return htmlCode;
}

function createMonthlySelect(name)
{
	var month = new Array;
    var htmlCode = "";
  
	month[0]="Jan";
	month[1]="Feb";
	month[2]="Mar";
	month[3]="Apr";
	month[4]="May";
	month[5]="Jun";
	month[6]="Jul";
	month[7]="Aug";
	month[8]="Sep";
	month[9]="Oct";
	month[10]="Nov";
	month[11]="Dec";
	
	var mydate = new Date();
	var mymonth = mydate.getMonth();
	var monthstring = "";
	
	htmlCode += "<select name=" + name + " size='1'>";
	
	for (var i = 0; i < 12; ++i) {
		if(i<9) {
			monthstring = "0" + (i+1);
		} else {
			monthstring = i+1;
		}
		
		if(mymonth+1 == monthstring) {
			htmlCode += "<option selected='selected' value='" + monthstring + "'>" + month[i] + "</option>";
		} else {
			htmlCode += "<option value='" + monthstring + "'>" + month[i] + "</option>";
		}
	}
	htmlCode += "</select>";
  
    return htmlCode;
}

function createYearlySelect(name)
{
	var mydate = new Date();
	var myyear = (mydate.getYear() % 1900) + 1900;
	var yearstring = "";
    var htmlCode = "";
  
	htmlCode += "<select name=" + name + " size='1'>";
	
	for (var i = 0; i < 51; ++i)
    {
		if (i < 10)
        {
			yearstring = "200" + i;
		} 
        else 
        {
			yearstring = "20" + i;
		}
		
        if (myyear == yearstring) 
        {
			htmlCode += "<option selected='selected' value='" + yearstring + "'>" + yearstring + "</option>";
		} 
        else 
        {
			htmlCode += "<option value='" + yearstring + "'>" + yearstring + "</option>";
		}
	}
	htmlCode += "</select>";
  
    return htmlCode;
}


function openNoaaFile(month, year)
{
    var url = "NOAA/NOAA-";
	
    url = url + year;
    if (month != '')
    {
        url = url + "-";
        url = url + month;
    }

    url = url + ".txt";
	$("#noaatext").text("\n\n\n           Loading....                             \n\n\n\n");
    /*window.location=url;*/
    $("#noaatext").load(url);
}

function openARCFile(day, month, year)
{
    var url = "Archive/ARC-" + year + "-" + month + "-" + day + ".txt";
    /*window.location=url;*/
	$("#noaatext").load(url);
}

function openURL(urlname)
{
    window.location=urlname;
}
