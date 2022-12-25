Attribute VB_Name = "mdlDigitiser_PostProcessRepair"
Option Explicit

' ################################################################################
' Usage:
'   This code is useful for working with yearly data.
'   Process Engague Digitiser CSV output file to make one row per year.
' Requirements:
'   Insert a new column "A" in the spreadsheet with sequencial numbers from the start to end year.
'   Change the gcRow_Start and gcEnd row to match the start/end year.
' ################################################################################

Const gcDEBUG_ExitAfterRows = 1000

Const gcRow_Header = 1
Const gcRow_Start = 2 'Second row with data
Const gcRow_End = 10000

Const gcCol_Security_Code = "A"
Const gcCol_Price_Dt = "B"
Const gcCol_Decimal_Year = "C"
Const gcCol_Value = "D"
Const gcCol_Comments = "E"

' --------------------------------------------------------------------------------
' Puropse:
'   Align for a Decimal Date and Value column.
' --------------------------------------------------------------------------------
Public Sub AlignHeaders()
    Dim oWks As Worksheet
    Set oWks = ThisWorkbook.Worksheets(1)
    
    Do While Len(oWks.Range("D1").Value) = 0
        oWks.Range("A:A").Select
        oWks.Range("A:A").Insert xlShiftToRight
    Loop
    
    oWks.Range("A1").Value = "Security_Code"
    oWks.Range("B1").Value = "Price_Dt"
    oWks.Range("C1").Value = "Decimal_Year"
    oWks.Range("D1").Value = "Value"
    oWks.Range("E1").Value = "Comments"
End Sub

' --------------------------------------------------------------------------------
' Puropse:
'   Insert Year Integers.
' --------------------------------------------------------------------------------
Public Sub Update_Price_Dt_Column()
    Dim i As Long
    Dim iStartYear As Integer
    Dim iEndYear As Integer
    
    Dim oWks As Worksheet
    Set oWks = ThisWorkbook.Worksheets(1)
    
    iStartYear = Round(CInt(oWks.Range(gcCol_Decimal_Year & CStr(gcRow_Start)).Value), 0)
    
    For i = gcRow_Start To gcRow_End
        oWks.Range(gcCol_Price_Dt & i).Value = iStartYear - gcRow_Start + i
        If (iEndYear = 0 And Len(oWks.Range(gcCol_Decimal_Year & i).Value) = 0) Then
            iEndYear = Round(CInt(oWks.Range(gcCol_Decimal_Year & CStr(i - 1)).Value), 0)
        End If
        If (iEndYear > 0 And iStartYear - gcRow_Start + i >= iEndYear) Then
            Exit For
        End If
    Next i
End Sub


Private Function GetRowEnd()
    Dim i As Long
    
    Dim oWks As Worksheet
    Set oWks = ThisWorkbook.Worksheets(1)
    For i = gcRow_Start To gcRow_End
        If Len(oWks.Range(gcCol_Price_Dt & CStr(i)).Value) = 0 Then
            GetRowEnd = i - 1
        End If
    Next i
End Function

' --------------------------------------------------------------------------------
' TODO: Need to fix gcCol_Price_Dt, gcCol_Decimal_Year to point to the correct columns.
'
' Usage:
'   Process CSV file to make one row per year.
'   Rows are deleted where there's more than one date in the same year and highlighted red.
'   Rows are inserted when there's missing years and highlighted yellow.
' Requirements:
'   Code must be modified for each use case.
'   Sequencial range of years in column A
'   Year decimal dates in column B
'   Values in Column C
'   Optionally, other values in column D
' Known Issue:
'   If the last two dates fall in the same year as the max year, the values can get pushed down
'   much further than they should.
' --------------------------------------------------------------------------------
Public Sub AlignDates()
    Dim iColA_Prev_Val As Integer
    Dim iColA_Val As Integer
    Dim iColA_Next_Val As Integer
    Dim iColB_Prev_Val As Integer
    Dim iColB_Val As Integer
    Dim iColB_Next_Val As Integer
    Dim i As Integer
    Dim j As Integer
    Dim oWks As Worksheet
    Dim sRowCol As String
    Dim lRowEnd As Long
    lRowEnd = GetRowEnd
    
    Set oWks = ThisWorkbook.Worksheets(1)
    
    j = 0
    For i = gcRow_Start + 1 To lRowEnd 'For Rows
        sRowCol = gcCol_Price_Dt & i - 1
        iColA_Prev_Val = CInt(oWks.Range(sRowCol))
        sRowCol = gcCol_Price_Dt & i
        iColA_Val = CInt(oWks.Range(sRowCol))
        sRowCol = gcCol_Price_Dt & i + 1
        iColA_Next_Val = CInt(oWks.Range(sRowCol))
        
        sRowCol = gcCol_Decimal_Year & i - 1
        iColB_Next_Val = Round(CDbl(oWks.Range(sRowCol)), 0)
        sRowCol = gcCol_Decimal_Year & i
        iColB_Val = Round(CDbl(oWks.Range(sRowCol)), 0)
        sRowCol = gcCol_Decimal_Year & i + 1
        iColB_Next_Val = Round(CDbl(oWks.Range(sRowCol)), 0)
        
        If (iColB_Val > 0 And iColB_Val > iColA_Val) Then
            j = j + 1
            If iColB_Next_Val > iColA_Next_Val Or iColB_Next_Val = 0 Then
                ' Shift Row
                Debug.Print ("Shift Row " & i & " down ")
                oWks.Range(gcCol_Decimal_Year & i, gcCol_Comments & i).Select
                oWks.Range(gcCol_Decimal_Year & i, gcCol_Comments & i).Insert (xlShiftDown)
                oWks.Range(gcCol_Decimal_Year & i, gcCol_Comments & i).Interior.Color = RGB(255, 255, 0)
            Else
                ' Change Date
                Debug.Print ("Change Date " & i)
                oWks.Range(gcCol_Decimal_Year & i).Value = iColA_Val
                oWks.Range(gcCol_Decimal_Year & i).Interior.Color = RGB(0, 255, 0)
            End If
        ElseIf (iColB_Val > 0 And iColB_Next_Val > 0 And _
            iColB_Val < iColA_Val And iColB_Next_Val < iColA_Next_Val) Then
            ' Delete Val
            j = j + 1
            Debug.Print ("Delete Val " & i)
            oWks.Range(gcCol_Decimal_Year & i, gcCol_Comments & i).Select
            oWks.Range(gcCol_Decimal_Year & i, gcCol_Comments & i).Delete (xlShiftUp)
            i = i - 1
            oWks.Range(gcCol_Decimal_Year & i, gcCol_Comments & i).Interior.Color = RGB(255, 0, 0)
            'TODO: Delete range doesn't compare the current and next values to the year
            ' so doesn't know if it should delete this value or move values!
        End If
        
        'DEBUG: Do this many rows then Exit
        If j > gcDEBUG_ExitAfterRows Then
            Exit For
        End If
    Next i
End Sub

' --------------------------------------------------------------------------------
' Purpose:
'   Add gcCol_Price_Dt for Actual to column "D" which will be the comments column.
' --------------------------------------------------------------------------------
Sub AddComments()
    Dim i As Integer
    Dim oWks As Worksheet
    Dim sRowCol As String
    Dim sCellVal As String
    Dim lRowEnd As Long
    lRowEnd = GetRowEnd
    
    Set oWks = ThisWorkbook.Worksheets(1)
    
    For i = gcRow_Start To lRowEnd 'For Rows
        sRowCol = "C" & i
        sCellVal = oWks.Range(sRowCol)
        If (Len(sCellVal) > 0) Then
            sRowCol = gcCol_Comments & i
            oWks.Range(sRowCol).Value = "A"
        End If
    Next i
End Sub

' --------------------------------------------------------------------------------
' Purpose:
'   Process CSV file to average known values where there's missing values.
' Requirements:
'   Code must be modified for each use case.
'   Sequencial range of years in column A
'   Year decimal dates in column B
'   Values in Column C
'   Optionally, other values in column D
' --------------------------------------------------------------------------------
Sub FixValues()
    Dim iColB_Prev_Val As Double
    Dim iColB_Val As Double
    Dim iColB_Next_Val As Double
    
    Dim lValDiff As Double
    Dim iRowDiff As Integer
    Dim sRowCol As String
    
    Dim i As Integer
    Dim j As Integer
    Dim l As Integer
    Dim oWks As Worksheet
    Dim lRowEnd As Long
    lRowEnd = GetRowEnd
    
    Set oWks = ThisWorkbook.Worksheets(1)
    
    l = 0
    For i = gcRow_Start + 1 To lRowEnd 'For Rows
        sRowCol = gcCol_Value & i - 1
        iColB_Prev_Val = CDbl(oWks.Range(sRowCol))
        sRowCol = gcCol_Value & i
        iColB_Val = CDbl(oWks.Range(sRowCol))
        
        If iColB_Val = 0 Then
            l = l + 1
            For j = i To lRowEnd
                sRowCol = gcCol_Value & j
                iColB_Next_Val = CDbl(oWks.Range(sRowCol))
                If iColB_Next_Val <> 0 Then
                    Debug.Print (i & ", " & j)
                    lValDiff = iColB_Next_Val - iColB_Prev_Val
                    iRowDiff = j - (i - 1)
                    iColB_Val = Round(iColB_Prev_Val + (lValDiff / iRowDiff), 4)
                    oWks.Range(gcCol_Value & i).Value = iColB_Val
                    Exit For
                End If
            Next j
        End If
        
        'DEBUG: Do this many rows then Exit
        If l > gcDEBUG_ExitAfterRows Then
            Exit For
        End If
    Next i
End Sub


