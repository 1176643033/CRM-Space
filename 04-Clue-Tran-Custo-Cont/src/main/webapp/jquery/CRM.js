//定义表单项类型
//类名：Form Item，属性包括两个：label、id
//这里的label相当于的id的值观形式
FormItem = function (label, id) {
    this.label = label;
    this.id = id;
}

//工具类
CRM = function () {

    //验证是否合法
    this.isPageNo = function (formItem,pagecount) {
        var id = formItem.id;
        var label = formItem.label;
        var domObj = document.getElementById(id);
        //非空验证
        if(domObj.value == ""){
            alert("请输入需要跳转的页数");
            return false;
        }

        //判断是否是数字,这里还需要更加完善，判断不是2.0，3.0之类小数
        if( isNaN(domObj.value) ){
            /*if (domObj.value.contains(".")){
                alert("请正确输入整型数字");
                return false;
            }*/
            alert("请正确输入整型数字");
            return false;
        }

        //范围验证
        if( 1 > domObj.value || domObj.value > pagecount ){
            alert("请输入正确范围");
            return false;
        }
        return true;
    }

    //验证非空(运行阶段次方法能接收数组，并且数组中每一个元素都是FormItem类型)
    this.isNotEmpty = function (formItemArr) {
        for(var i=0; i<formItemArr.length; i++){
            var formItem = formItemArr[i];
            var id = formItem.id;
            var label = formItem.label;
            var domObj = document.getElementById(id);
            if (domObj.value.trim() == ""){
                alert(label + "不能为空，请填写");
                domObj.focus();
                return false;
            }
        }
        return true;
    }

    //验证一致(程序运行的时候formItem1和formItem2都是FormItem类型的对象)
    this.isSame = function (formItem1, formItem2) {

        var id1 = formItem1.id;
        var id2 = formItem2.id;
        var label1 = formItem1.label;
        var label2 = formItem2.label;
        var domObj1 = document.getElementById(id1);
        var domObj2 = document.getElementById(id2);
        if(domObj1.value != domObj2.value){
            alert(label1+"和"+label2+"不一致，请重新填写！");
            domObj1.value = "";
            domObj2.value = "";
            domObj1.focus();
            return false;
        }
        return true;

    }

}

