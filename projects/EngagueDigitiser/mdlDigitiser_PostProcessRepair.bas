Attribute VB_Name = "mdlDigitiser_PostProcessRepair"
Option Explicit

' --------------------------------------------------------------------------------
' Usage:
'   Process Engague Digitiser CSV output file to make one row per year.
'   Rows are deleted where there's more than one date in the same year.
'   Rows are inserted when there's missing years.
' Requirements:
'   Code must be modified for each use case.
'   Sequencial range of years in column A
'   Year decimal dates in column B
'   Values in Column C
'   Optionally, other values in column D
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
    
    Set oWks = ThisWorkbook.Worksheets(1)
    
    j = 0
    For i = 2 To 848 'For Rows
        iColA_Prev_Val = CInt(oWks.Range("A" & i - 1))
        iColA_Val = CInt(oWks.Range("A" & i))
        iColA_Next_Val = CInt(oWks.Range("A" & i + 1))
        
        iColB_Next_Val = Round(CDbl(oWks.Range("B" & i - 1)), 0)
        iColB_Val = Round(CDbl(oWks.Range("B" & i)), 0)
        iColB_Next_Val = Round(CDbl(oWks.Range("B" & i + 1)), 0)
        
        If (iColB_Val > 0 And iColB_Val > iColA_Val) Then
            j = j + 1
            If iColB_Next_Val > iColA_Next_Val Or iColB_Next_Val = 0 Then
                ' Shift Row
                Debug.Print ("Shift Row Down " & i)
                oWks.Range("B" & i, "D" & i).Select
                oWks.Range("B" & i, "D" & i).Insert (xlShiftDown)
                oWks.Range("B" & i, "D" & i).Interior.Color = RGB(255, 255, 0)
            Else
                ' Change Date
                Debug.Print ("Change Date " & i)
                oWks.Range("B" & i).Value = iColA_Val
                oWks.Range("B" & i).Interior.Color = RGB(0, 255, 0)
            End If
        ElseIf (iColB_Val > 0 And iColB_Next_Val > 0 And _
            iColB_Val < iColA_Val And iColB_Next_Val < iColA_Next_Val) Then
            ' Delete Val
            j = j + 1
            Debug.Print ("Delete Val " & i)
            oWks.Range("B" & i, "D" & i).Select
            oWks.Range("B" & i, "D" & i).Delete (xlShiftUp)
            i = i - 1
            oWks.Range("B" & i, "D" & i).Interior.Color = RGB(255, 0, 0)
            'TODO: Delete range doesn't compare the current and next values to the year
            ' so doesn't know if it should delete this value or move values!
        End If

        If j > 10 Then
            Exit For
        End If
    Next i
End Sub

' --------------------------------------------------------------------------------
' Purpose:
'   Process Engague Digitiser CSV output file to average known values where there's missing values.
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
    
    Dim i As Integer
    Dim j As Integer
    Dim l As Integer
    Dim oWks As Worksheet
        
    Set oWks = ThisWorkbook.Worksheets(1)
    
    l = 0
    For i = 3 To 848 'For Rows
        iColB_Prev_Val = CDbl(oWks.Range("B" & i - 1))
        iColB_Val = CDbl(oWks.Range("B" & i))
        
        If iColB_Val = 0 Then
            l = l + 1
            For j = i To 848
                iColB_Next_Val = CDbl(oWks.Range("B" & j))
                If iColB_Next_Val <> 0 Then
                    Debug.Print (i & ", " & j)
                    lValDiff = iColB_Next_Val - iColB_Prev_Val
                    iRowDiff = j - (i - 1)
                    iColB_Val = Round(iColB_Prev_Val + (lValDiff / iRowDiff), 4)
                    oWks.Range("B" & i).Value = iColB_Val
                    Exit For
                End If
            Next j
        End If
        
        If l > 10 Then
            Exit For
        End If
    Next i
End Sub
