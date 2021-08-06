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

		//引用bootstrap的日期选择器
		$(".time").datetimepicker({
			minView: "month",
			language: "zh-CN",
			format: "yyyy-mm-dd",
			autoclose: true,
			today: true,
			pickerPosition: "bottom-left"
		})

		//创建按钮绑定事件,打开添加操作的模态窗口
		$("#addBtn").click(function(){

			$("#activityAddForm")[0].reset(); //重置表单
			$.ajax({
				url : "workbench/activity/getUserList.do",
				dataType : "json",
				success : function (data) {
					$("#create-owner").empty();		//清空
					//塞入数据
					var html = "";
					$.each(data, function(i, n){
						html += "<option value='"+n.id+"'>"+n.name+"</option>";
					})
					$("#create-owner").html(html);
					//默认选中当前登录用户
					$("#create-owner").val("${sessionScope.user.id}");
				}
			})

			$("#createActivityModal").modal("show");
		})
		
		//为保存按钮绑定事件
		$("#saveBtn").click(function () {
			$.ajax({
				url : "workbench/activity/save.do",
				data : {
					"owner" : $.trim($("#create-owner").val()),
					"name" : $.trim($("#create-name").val()),
					"startDate" : $.trim($("#create-startDate").val()),
					"endDate" : $.trim($("#create-endDate").val()),
					"cost" : $.trim($("#create-cost").val()),
					"description" : $.trim($("#create-description").val())
				},
				type : "post",
				dataType: "json",
				success : function (data) {

					if(data){
						$("#createActivityModal").modal("hide");
					}else{
						alert("添加市场活动失败");
					}
					pageList(1,$("#activityPage").bs_pagination('getOption', 'rowsPerPage'));
				}
			})
		})

		//查询按钮绑定事件
		$("#searchBtn").click(function () {
			//把 四个参数值保存在隐藏域中
			$("#hidden-name").val($.trim($("#search-name").val()))
			$("#hidden-owner").val( $.trim($("#search-owner").val()))
			$("#hidden-startDate").val($.trim($("#search-startDate").val()))
			$("#hidden-endDate").val($.trim($("#search-endDate").val()))
			pageList(1,$("#activityPage").bs_pagination('getOption', 'rowsPerPage'));
		})

		//删除按钮绑定事件
		$("#deleteBtn").click(function(){
			//找到数据行复选框选中的数量
			var $chkItem = $("input[name=chkItem]:checked");

			if($chkItem.length == 0){ alert("请选择需要删除的记录"); }
			else{
				if(confirm("确定删除选中的记录吗?")){

					//拼接url后面的参数 id=xxx&id=xxx&id=xxxx
					var param = "";
					//遍历dom对象取id值
					for(var i=0; i<$chkItem.length; i++){
						param += "id="+$($chkItem[i]).val();
						//如果不是最后一个元素则在后面追加"&"符
						if( i<$chkItem.length-1 ){ param += "&"; }
					}
					$.ajax({
						url : "workbench/activity/delete.do",
						data : param,
						type : "post",
						dataType : "json",
						success : function(data){
							if (data){
								//删除成功
								pageList(1,$("#activityPage").bs_pagination('getOption', 'rowsPerPage'));

							}else {
								alert("删除市场活动失败");
							}
						}
					})
				}
			}
		})

		//编辑按钮绑定事件
		$("#editBtn").click(function(){
			//找到数据行复选框选中的数量
			var $chkItem = $("input[name=chkItem]:checked");

			if($chkItem.length == 0){ alert("请选择需要编辑的记录"); }
			else if($chkItem.length > 1){ alert("每次只能修改一条记录!")}
			else{
				//获取activity对象后打开模态窗口
				$.ajax({
					url : "workbench/activity/getActivityById.do",
					data : {"id" : $chkItem.val()},
					dataType : "json",
					success : function(data){
						//加载所有者信息列表
						$("#edit-owner").empty();		//清空
						var html = "";
						$.each(data.userList, function(i, n){
							html += "<option value='"+n.id+"'>"+n.name+"</option>";
						})

						$("#edit-owner").html(html);
						$("#edit-owner").val(data.activity.owner);
						$("#edit-name").val(data.activity.name);
						$("#edit-startDate").val(data.activity.startDate);
						$("#edit-endDate").val(data.activity.endDate);
						$("#edit-cost").val(data.activity.cost)
						$("#edit-description").val(data.activity.description)

						$("#editActivityModal").modal("show");
					}
				})
			}
		})

		//更新按钮绑定事件
		$("#updateBtn").click(function () {
			$.ajax({
				url : "workbench/activity/update.do",
				data : {
					"id" : $("input[name=chkItem]:checked").val(),
					"owner" : $.trim($("#edit-owner").val()),
					"name" : $.trim($("#edit-name").val()),
					"startDate" : $.trim($("#edit-startDate").val()),
					"endDate" : $.trim($("#edit-endDate").val()),
					"cost" : $.trim($("#edit-cost").val()),
					"description" : $.trim($("#edit-description").val()),
					"editBy" : "${sessionScope.user.name}"
				},
				type : "post",
				dataType: "json",
				success : function (data) {
					if(data){
						$("#editActivityModal").modal("hide");
					}else{
						alert("更新市场活动失败");
					}
					//设置更新后停留在当前页
					pageList($("#activityPage").bs_pagination('getOption', 'currentPage')
							,$("#activityPage").bs_pagination('getOption', 'rowsPerPage'));
				}
			})
		})

		/*
		数据行的复选框发生改变时的事件处理函数
		动态生成的元素要以on形式来触发事件
		语法: $(需要绑定的元素的有效外层元素).on(绑定事件的方式, 需要绑定的元素的jQuery对象, 回调函数)

	 */
		//数据行复选框绑定事件
		$("#activityBody").on("click",$("input[name=chkItem]"),function () {
			$("input[name=chkAll]").prop("checked",$("input[name=chkItem]").length == $("input[name=chkItem]:checked").length);
		})
		//全选复选框绑定事件
		$("input[name=chkAll]").click(function () {
			$("input[name=chkItem]").prop("checked", this.checked);
		})
		/*
		* $("#activityPage").bs_pagination('getOption', 'currentPage')
		* 操作后停留在当前页
		*
		* $("#activityPage").bs_pagination('getOption', 'rowsPerPage')
		* 表示操作后维持已经设置好的每页展现的记录数
		*/


		//初次进来页面时加载,设置pageSize为5
		pageList(1,5);
	});

	/*
		对于所有的关系新数据库,做前端分页操作的基础参数是页数和展示的记录条数

		需要调用此方法的情况:
		1.点击左侧菜单中的"市场活动"的超链接  v
		2.添加、修改、删除后需要更新列表    v
		3.点击查询按钮的时候，需要刷新列表	v
		4.点击分页组件的时候，刷新列表		v
	 */
	function pageList(pageNo, pageSize) {

		$("input[name=chkAll]").prop("checked", false);

		$.ajax({
			url : "workbench/activity/pageList.do",
			data : {
				"pageNo" : pageNo,
				"pageSize" : pageSize,
				"name" : $("#hidden-name").val(),
				"owner" : $("#hidden-owner").val(),
				"startDate" : $("#hidden-startDate").val(),
				"endDate" : $("#hidden-endDate").val()
			},
			dataType : "json",
			success : function (data) {

				$("#activityBody").empty();
				// data : 包含一个总记录条数 "total" 以及 数据列表 "dataList"
				$.each(data.dataList, function(i,n){
					$("#activityBody").append(  '<tr class="active">' +
													'<td><input type="checkbox" name="chkItem" value="'+n.id+'"/></td>' +
													'<td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href=\'workbench/activity/detail.do?id='+n.id+'\';">'+n.name+'</a></td>' +
													' <td>'+n.owner+'</td>' +
													'<td>'+n.startDate+'</td>' +
													'<td>'+n.endDate+'</td>' +
												'</tr>' );
				})

				//计算总页数
				var totalPages = data.total%pageSize==0 ? data.total/pageSize : parseInt(data.total/pageSize)+1;

				//在pageList.do处理ajax返回值后，加入分页组件
				$("#activityPage").bs_pagination({
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
	<input type="hidden" id="hidden-name" />
	<input type="hidden" id="hidden-owner" />
	<input type="hidden" id="hidden-startDate" />
	<input type="hidden" id="hidden-endDate" />

	<!-- 创建市场活动的模态窗口 -->
	<div class="modal fade" id="createActivityModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 85%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel1">创建市场活动</h4>
				</div>
				<div class="modal-body">
				
					<form id="activityAddForm" class="form-horizontal" role="form">
					
						<div class="form-group">
							<label for="create-marketActivityOwner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-owner">
								  <!--创建  ajax塞入数据-->
								</select>
							</div>
                            <label for="create-marketActivityName" class="col-sm-2 control-label">名称<span style="font-size: 15px; color: red;">*</span></label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="create-name">
                            </div>
						</div>
						
						<div class="form-group">
							<label for="create-startTime" class="col-sm-2 control-label">开始日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control  time" id="create-startDate" readonly>
							</div>
							<label for="create-endTime" class="col-sm-2 control-label">结束日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control  time" id="create-endDate" readonly>
							</div>
						</div>
                        <div class="form-group">

                            <label for="create-cost" class="col-sm-2 control-label">成本</label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="create-cost">
                            </div>
                        </div>
						<div class="form-group">
							<label for="create-describe" class="col-sm-2 control-label">描述</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="create-description"></textarea>
							</div>
						</div>
						
					</form>
					
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" class="btn btn-primary" id="saveBtn">保存</button>
				</div>
			</div>
		</div>
	</div>
	
	<!-- 修改市场活动的模态窗口 -->
	<div class="modal fade" id="editActivityModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 85%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel2">修改市场活动</h4>
				</div>
				<div class="modal-body">
				
					<form class="form-horizontal" role="form">
					
						<div class="form-group">
							<label for="edit-marketActivityOwner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-owner">
								  <!--ajax动态塞入数据-->
								</select>
							</div>
                            <label for="edit-marketActivityName" class="col-sm-2 control-label">名称<span style="font-size: 15px; color: red;">*</span></label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="edit-name" >
                            </div>
						</div>

						<div class="form-group">
							<label for="edit-startTime" class="col-sm-2 control-label">开始日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control time" id="edit-startDate" readonly >
							</div>
							<label for="edit-endTime" class="col-sm-2 control-label">结束日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control time" id="edit-endDate" readonly>
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-cost" class="col-sm-2 control-label">成本</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-cost" >
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-describe" class="col-sm-2 control-label">描述</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="edit-description"></textarea>
							</div>
						</div>
						
					</form>
					
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" class="btn btn-primary" id="updateBtn">更新</button>
				</div>
			</div>
		</div>
	</div>

	
	<div>
		<div style="position: relative; left: 10px; top: -10px;">
			<div class="page-header">
				<h3>市场活动列表</h3>
			</div>
		</div>
	</div>
	<div style="position: relative; top: -20px; left: 0px; width: 100%; height: 100%;">
		<div style="width: 100%; position: absolute;top: 5px; left: 10px;">
		
			<div class="btn-toolbar" role="toolbar" style="height: 80px;">
				<form class="form-inline" role="form" style="position: relative;top: 8%; left: 5px;">
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">名称</div>
				      <input class="form-control" type="text" id="search-name">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">所有者</div>
				      <input class="form-control" type="text" id="search-owner">
				    </div>
				  </div>


				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">开始日期</div>
					  <input class="form-control time" type="text" id="search-startDate" readonly>
						<!--<input type="text" class="form-control  time" id="create-endDate" readonly>-->
				    </div>
				  </div>
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">结束日期</div>
					  <input class="form-control time" type="text" id="search-endDate" readonly>
				    </div>
				  </div>
				  
				  <button type="button" id="searchBtn" class="btn btn-default">查询</button>
				  
				</form>
			</div>
			<div class="btn-toolbar" role="toolbar" style="background-color: #F7F7F7; height: 50px; position: relative;top: 5px;">
				<div class="btn-group" style="position: relative; top: 18%;">
					<!--
						data-toggle="modal": 表示触发该按钮,将要打开一个模态窗口
						data-target="#xxxx": 表示要打开哪个模态窗口.通过#id的形式找到该窗口

						现在我们是以熟悉和属性值的方式写在了button元素中,用来打开模态窗口
						但是这样做的问题是没有办法对按钮的功能进行扩充.

						所以在实际项目开发对于触发模态窗口的操作一定不要写死在元素当中,应该由js代码来操作
					-->
				  <button type="button" class="btn btn-primary" id="addBtn"><span class="glyphicon glyphicon-plus"></span> 创建</button>
				  <button type="button" class="btn btn-default" id="editBtn" data-target="#editActivityModal"><span class="glyphicon glyphicon-pencil"></span> 修改</button>
				  <button type="button" class="btn btn-danger" id="deleteBtn"><span class="glyphicon glyphicon-minus"></span> 删除</button>
				</div>
				
			</div>
			<div style="position: relative;top: 10px;">
				<table class="table table-hover">
					<thead>
						<tr style="color: #B3B3B3;">
							<td><input type="checkbox" name="chkAll" /></td>
							<td>名称</td>
                            <td>所有者</td>
							<td>开始日期</td>
							<td>结束日期</td>
						</tr>
					</thead>
					<tbody id="activityBody">
						<!--pageList函数中塞入数据-->
					</tbody>
				</table>
			</div>
			
			<div style="height: 50px; position: relative;top: 30px;">
				<div id="activityPage"></div>
			</div>
			
		</div>
		
	</div>
</body>
</html>