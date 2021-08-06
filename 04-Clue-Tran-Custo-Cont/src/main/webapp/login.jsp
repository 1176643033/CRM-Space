<%--
Created by IntelliJ IDEA.
User: Chieh
Date: 2021/6/25
Time: 9:39
To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
String path = request.getContextPath();
String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath() + "/";
%>

<html>
<head>
	<base href="<%=basePath%>"/>
	<meta charset="UTF-8">
	<link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet" />
	<script type="text/javascript" src="jquery/jQuery3.5.js"></script>
	<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>

	<!--引入自行编写的组件校验工具包-->
	<script type="text/javascript" src="jquery/CRM.js"></script>

	<script type="text/javascript">
		$(function () {

			if(window.top != window){
				window.top.location = window.location;
			}

			//页面加载完毕后,将用户文本框中的内容清空
			$("#loginAct").val("");

			//页面加载完毕后，让用户的文本框自动获取焦点
			$("#loginAct").focus();
			$("#submitBtn").click(function () {
				login();
			})

			$(window).keydown(function (event){
				if(event.keyCode==13){
					login();
				}
				$("#msg").empty();
			})
		})

		//普通function写在$(function(){})	的外面
		function login() {

			//验证非空才发送ajax
			if( validateForm() ){
				$.post({
					url:"setting/user/login.do",
					data:{
						"loginAct":$("#loginAct").val(),
						"loginPwd":$("#loginPwd").val()
					},
					dataType:"json",
					success:function (resp) {
						//resp包含success(true/false)和msg
						//登录成功
						if(resp.success){
							//跳转到工作台的初始页面
							window.location.href = "workbench/index.jsp"
						}
						else{
							$("#msg").html(resp.msg);
						}
					}
				})
			}
		}

		//调用crm.js校验表单项
		function validateForm() {
			var crm = new CRM();
			var formItem1 = new FormItem("用户名","loginAct");
			var formItem2 = new FormItem("密码","loginPwd");
			var formItemArr = [formItem1,formItem2];

			return crm.isNotEmpty(formItemArr);
		}

	</script>
</head>
<body>
	<div style="position: absolute; top: 0px; left: 0px; width: 60%;">
		<img src="image/IMG_7114.JPG" style="width: 100%; height: 90%; position: relative; top: 50px;">
	</div>
	<div id="top" style="height: 50px; background-color: #3C3C3C; width: 100%;">
		<div style="position: absolute; top: 5px; left: 0px; font-size: 30px; font-weight: 400; color: white; font-family: 'times new roman'">CRM &nbsp;<span style="font-size: 12px;">&copy;2017&nbsp;动力节点</span></div>
	</div>
	
	<div style="position: absolute; top: 120px; right: 100px;width:450px;height:400px;border:1px solid #D5D5D5">
		<div style="position: absolute; top: 0px; right: 60px;">
			<div class="page-header">
				<h1>登录</h1>
			</div>
			<form action="workbench/index.jsp" class="form-horizontal" role="form">
				<div class="form-group form-group-lg">
					<div style="width: 350px;">
						<input class="form-control" type="text" placeholder="用户名" id="loginAct">
					</div>
					<div style="width: 350px; position: relative;top: 20px;">
						<input class="form-control" type="password" placeholder="密码" id="loginPwd">
					</div>
					<div class="checkbox"  style="position: relative;top: 30px; left: 10px;">
						
							<span id="msg" style="color: red"></span>
						
					</div>
					<!-- form表单中的按钮一定要设置type为buttton-->
					<button id="submitBtn" type="button" class="btn btn-primary btn-lg btn-block"  style="width: 350px; position: relative;top: 45px;">登录</button>
				</div>
			</form>
		</div>
	</div>
</body>
</html>