echo %1 > tmp1
dirname %1 > tmp13
echo \history\ > tmp14
echo @ > tmp20
tr "@" "\042" < tmp20 > tmp21
paste -d '\0' tmp13 tmp14 tmp21 > tmp15
tr -d "'" < tmp15 > tmp16 
echo @ > tmp22
paste -d '\0' tmp22 tmp16 > tmp23
tr -d "@" < tmp23 | tr "'" "\042" > tmp24
echo copy > tmp3 
set timestuff=+"%%Y%%m%%d%%H%%M."
c:\windows\date.exe %timestuff% > tmp4
whoami > tmp5
cut -d "." -f 1 tmp1 > tmp8
cut -d "." -f 2 tmp1 > tmp9
paste -d '\0' tmp8 tmp4 tmp5 tmp9 > tmp10
tr "\011" "." < tmp10 | tr -d "\377" | tr "'" "." > tmp11
paste -d '\0' tmp3 tmp1 tmp11 > tmp12 
tr -d "'" < tmp12 > tmp7.bat
call tmp7
echo move > tmp17
paste tmp17
dirname tmp24
paste -d '\0' tmp17 tmp11 tmp24 > tmp18
tr -d "'" < tmp18 > tmp19.bat
echo mkdir > tmp25
paste -d '\0' tmp25 tmp24 > tmp26
tr -d "'" < tmp26 > tmp27.bat
call tmp27.bat
call tmp19.bat
rem %1 This would open the file if desired.
del tmp1 tmp3 tmp4 tmp5 tmp6 tmp8 tmp9 tmp10 tmp11 tmp12 tmp13 tmp14 tmp15 tmp16 
del tmp17 tmp18 tmp20 tmp21 tmp22 tmp23 tmp24 tmp25 tmp26 tmp7.bat tmp19.bat tmp27.bat




