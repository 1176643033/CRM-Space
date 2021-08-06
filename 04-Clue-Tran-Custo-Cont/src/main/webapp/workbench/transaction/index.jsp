<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
String path = request.getContextPath();
String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath() + "/";
%>

<html>
<head>
	<base href="<%=basePath%>"/>
	<meta charset="UTF-8">

<link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet" />
<link href="jquery/bootstrap-datetimepicker-master/css/bootstrap-datetimepicker.min.css" type="text/css" rel="stylesheet" />

<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.js"></script>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js"></script>

	<link rel="stylesheet" type="text/css" href="jquery/bs_pagination/jquery.bs_pagination.min.css">
	<script type="text/javascript" src="jquery/bs_pagination/jquery.bs_pagination.min.js"></script>
	<script type="text/javascript" src="jquery/bs_pagination/en.js"></script>

<script type="text/javascript">

	$(function(){

		//查询按钮绑定事件
		$("#searchBtn").click(function () {
			//把参数值保存在隐藏域中
			$("#hidden-owner").val($.trim($("#search-owner").val()))
			$("#hidden-name").val( $.trim($("#search-name").val()))
			$("#hidden-customerName").val($.trim($("#search-customerName").val()))
			$("#hidden-stage").val($.trim($("#search-stage").val()))
			$("#hidden-type").val($.trim($("#search-type").val()))
			$("#hidden-source").val($.trim($("#search-source").val()))
			$("#hidden-contactsName").val($.trim($("#search-contactsName").val()))
			pageList(1,$("#tranPage").bs_pagination('getOption', 'rowsPerPage'));
		})

		//编辑按钮绑定事件
		$("#editBtn").click(function(){
			//找到数据行复选框选中的数量
			var $chkItem = $("input[name=chkItem]:checked");

			if($chkItem.length == 0){ alert("请选择需要编辑的记录"); }
			else if($chkItem.length > 1){ alert("每次只能修改一条记录!")}
			else{
				window.location.href = "workbench/transaction/edit.do?id="+$chkItem.val();
			}
		})


		//删除按钮绑定事件
		$("#deleteBtn").click(function(){
			//找到数据行复选框选中的数量
			var $chkItem = $("input[name=chkItem]:checked");

			if($chkItem.length == 0){ alert("请选择需要删除的记录"); }
			else{
				if(confirm("确定删除选中的记录吗?")){
					alert("前端和后端都还没实现")
					/*//拼接url后面的参数 id=xxx&id=xxx&id=xxxx
					var param = "";
					//遍历dom对象取id值
					for(var i=0; i<$chkItem.length; i++){
						param += "id="+$($chkItem[i]).val();
						//如果不是最后一个元素则在后面追加"&"符
						if( i<$chkItem.length-1 ){ param += "&"; }
					}
					window.location.href="workbench/transaction/edit.do?id="+带值*/
				}
			}
		})

		//数据行复选框绑定事件
		$("#tranBody").on("click",$("input[name=chkItem]"),function () {
			$("input[name=chkAll]").prop("checked",$("input[name=chkItem]").length == $("input[name=chkItem]:checked").length);
		})
		//全选复选框绑定事件
		$("input[name=chkAll]").click(function () {
			$("input[name=chkItem]").prop("checked", this.checked);
		})

		pageList(1,5)
		
	});

	function pageList(pageNo, pageSize) {

		$("input[name=chkAll]").prop("checked", false);

		$.ajax({
			url : "workbench/transaction/pageList.do",
			data : {
				"pageNo" : pageNo,
				"pageSize" : pageSize,
				"owner" : $("#hidden-owner").val(),
				"name" : $("#hidden-name").val(),
				"customerName" : $("#hidden-customerName").val(),
				"stage" : $("#hidden-stage").val(),
				"type" : $("#hidden-type").val(),
				"source" : $("#hidden-source").val(),
				"contactsName" : $("#hidden-contactsName").val()
			},
			dataType : "json",
			success : function (data) {

				$("#tranBody").empty();
				// data : 包含一个总记录条数 "total" 以及 数据列表 "dataList"
				$.each(data.dataList, function(i,n){
					$("#tranBody").append(
							'<tr>\n' +
							'<td><input type="checkbox" name="chkItem" value="'+n.id+'" /></td>\n' +
							'<td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href=\'workbench/transaction/detail.do?id='+n.id+'\';">'+n.name+'</a></td>\n' +
							'<td>'+n.customerId+'</td>\n' +
							'<td>'+n.stage+'</td>\n' +
							'<td>'+n.type+'</td>\n' +
							'<td>'+n.owner+'</td>\n' +
							'<td>'+n.source+'</td>\n' +
							'<td>'+n.contactsId+'</td>\n' +
							'</tr>');
				})

				//计算总页数
				var totalPages = data.total%pageSize==0 ? data.total/pageSize : parseInt(data.total/pageSize)+1;

				//在pageList.do处理ajax返回值后，加入分页组件
				$("#tranPage").bs_pagination({
					currentPage: pageNo, // 页码
					rowsPerPage: pageSize, // 每页显示的记录条数
					maxRowsPerPage: 20, // 每页最多显示的记录条数
					totalPages: totalPages, // 总页数
					totalRows: data.total, // 总记录条数

					visiblePageLinks: 3, // 显示几个卡片

					showGoToPage: true,
					showRowsPerPage: true,
					showRowsInfo: true,
					showRowsDefaultInfo: true,

					//该回调函数, 点击分页组件的时候触发
					onChangePage : function(event, data){
						pageList(data.currentPage , data.rowsPerPage);
					}
				});

			}
		})

	}
	
</script>
</head>
<body>

	<!--隐藏域用于存储每次点击查询时的参数-->
	<input type="hidden" id="hidden-owner" />
	<input type="hidden" id="hidden-name" />
	<input type="hidden" id="hidden-customerName" />
	<input type="hidden" id="hidden-stage" />
	<input type="hidden" id="hidden-type" />
	<input type="hidden" id="hidden-source" />
	<input type="hidden" id="hidden-contactsName" />
	
	<div>
		<div style="position: relative; left: 10px; top: -10px;">
			<div class="page-header">
				<h3>交易列表</h3>
			</div>
		</div>
	</div>
	
	<div style="position: relative; top: -20px; left: 0px; width: 100%; height: 100%;">
	
		<div style="width: 100%; position: absolute;top: 5px; left: 10px;">
		
			<div class="btn-toolbar" role="toolbar" style="height: 80px;">
				<form class="form-inline" role="form" style="position: relative;top: 8%; left: 5px;">
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">所有者</div>
				      <input class="form-control" type="text" id="search-owner">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">名称</div>
				      <input class="form-control" type="text" id="search-name">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">客户名称</div>
				      <input class="form-control" type="text" id="search-customerName">
				    </div>
				  </div>
				  
				  <br>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">阶段</div>
					  <select class="form-control" id="search-stage">
					  	<option></option>
						  <c:forEach items="${stageList}" var="s">
							  <option></option>
							  <option value="${s.value}">${s.text}</option>
						  </c:forEach>
					  </select>
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">类型</div>
					  <select class="form-control" id="search-type">
					  	<option></option>
						  <c:forEach items="${transactionTypeList}" var="t">
							  <option value="${t.value}">${t.text}</option>
						  </c:forEach>
					  </select>
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">来源</div>
				      <select class="form-control" id="search-source">
						  <option></option>
						  <c:forEach items="${sourceList}" var="s">
							  <option></option>
							  <option value="${s.value}">${s.text}</option>
						  </c:forEach>
						</select>
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">联系人名称</div>
				      <input class="form-control" type="text" id="search-contactsName">
				    </div>
				  </div>
				  
				  <button type="button" class="btn btn-default" id="searchBtn">查询</button>
				  
				</form>
			</div>
			<div class="btn-toolbar" role="toolbar" style="background-color: #F7F7F7; height: 50px; position: relative;top: 10px;">
				<div class="btn-group" style="position: relative; top: 18%;">
				  <button type="button" class="btn btn-primary" onclick="window.location.href='workbench/transaction/add.do';"><span class="glyphicon glyphicon-plus"></span> 创建</button>
				  <button type="button" class="btn btn-default" id="editBtn"><span class="glyphicon glyphicon-pencil"></span> 修改</button>
				  <button type="button" class="btn btn-danger" id="deleteBtn"><span class="glyphicon glyphicon-minus"></span> 删除</button>
				</div>
				
				
			</div>
			<div style="position: relative;top: 10px;">
				<table class="table table-hover">
					<thead>
						<tr style="color: #B3B3B3;">
							<td><input type="checkbox" name="chkAll" /></td>
							<td>名称</td>
							<td>客户名称</td>
							<td>阶段</td>
							<td>类型</td>
							<td>所有者</td>
							<td>来源</td>
							<td>联系人名称</td>
						</tr>
					</thead>
					<tbody id="tranBody">
						<!--ajax塞入数据列表-->
					</tbody>
				</table>
			</div>
			
			<div style="height: 50px; position: relative;top: 20px;">
				<div id="tranPage"></div>
			</div>
			
		</div>
		
	</div>
</body>
</html>