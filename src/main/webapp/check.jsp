<%@ include file="header.jsp" %>
<%@ page import="java.sql.DriverManager" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%

    long lid = request.getParameter("licenseId") == null ? -1 : Long.parseLong((String) request.getParameter("licenseId"));
    String ciid = (String) request.getParameter("contentItemId");

    Class.forName("oracle.jdbc.driver.OracleDriver");
    String dbUrl = "jdbc:oracle:thin:@//CAR-LNDSSDBP-02.wiley.com:1593/DSSPROD";
    Connection conn = DriverManager.getConnection(dbUrl, "cdts", "cdts");
    PreparedStatement preparedStatement = conn.prepareStatement(
            "SELECT pi.id, pi.loaderKey, pi.remoteName, pi.packageSize, pi.contentItemId, l.id as \"lid\", l.name, pi.stateCode, pi.modifiedDateTime, df.id as \"dfid\" " +
                    "FROM Push_Item pi, License l, Delivery_Format df " +
                    "WHERE df.id=l.deliveryFormatId AND pi.licenseId=l.id AND l.id=? AND pi.contentItemId=? " +
                    "ORDER BY modifiedDateTime");
    preparedStatement.setLong(1, lid);
    preparedStatement.setString(2, ciid);
    ResultSet result = preparedStatement.executeQuery();

    String dbUrl2 = "jdbc:oracle:thin:@//AUS-LNDSSDBP-03.wiley.com:1593/DSSPRD";
    Connection conn2 = DriverManager.getConnection(dbUrl2, "DSS", "DSS");
    PreparedStatement preparedStatement2 = conn2.prepareStatement(
            "SELECT pi.id, pi.loaderKey, pi.remoteName, pi.packageSize, pi.contentItemId, l.id as \"lid\", l.name, pi.stateCode, pi.modifiedDateTime, df.id as \"dfid\" " +
                    "FROM Push_Item pi, License l, Delivery_Format df " +
                    "WHERE df.id=l.deliveryFormatId AND pi.licenseId=l.id AND l.id=? AND pi.contentItemId=? " +
                    "ORDER BY modifiedDateTime");
    preparedStatement2.setLong(1, lid);
    preparedStatement2.setString(2, ciid);
    ResultSet result2 = preparedStatement2.executeQuery();

%>

<table>
    <tr>
        <td valign="top">
            <h1>Production Deliveries</h1>
            <% while (result.next()) { %>
            <table width="50%" bgcolor="#add8e6">
                <tr><td style="font-size:larger">Id</td></td><td style="font-size:larger"><%= result.getLong("id")%></td></tr>
                <tr><td style="font-size:larger">LoaderKey</td><td style="font-size:larger"><a target="_blank" href="http://dss.wiley.com:8080/ui/#/activity_log/<%= result.getLong("loaderKey")%>"><%= result.getLong("loaderKey")%></a></td></tr>
                <tr><td style="font-size:larger">Size</td><td style="font-size:larger"><%= result.getLong("packageSize")%></td></tr>
                <tr><td style="font-size:larger">Package</td><td style="font-size:larger"><%= result.getString("remoteName")%></td></tr>
                <tr><td style="font-size:larger">CIID</td><td style="font-size:larger"><a target="_blank" href="content.jsp?contentItemId=<%= result.getString("contentItemId")%>"><%= result.getString("contentItemId")%></a></td></tr>
                <tr><td style="font-size:larger">LID</td><td style="font-size:larger"><%= result.getLong("lid")%></td></tr>
                <tr><td style="font-size:larger">L.Name</td><td style="font-size:larger"><%= result.getString("name")%></td></tr>
                <tr><td style="font-size:larger">Status</td><td style="font-size:larger"><%= result.getString("stateCode")%></td></tr>
                <tr><td style="font-size:larger">Modified</td><td style="font-size:larger"><%= result.getTimestamp("modifiedDateTime")%></td></tr>
                <tr><td style="font-size:larger" colspan="2"><a href="/resteasy/id/<%= result.getString("contentItemId")%>/format/<%= result.getLong("dfid")%>?fileDownload=true">Download Package</a></td></tr>
            </table>
            <br>
            <% } %>
        </td>
        <td>&nbsp;</td>
        <td valign="top">
            <h1>Pre-Production Deliveries</h1>
            <% while (result2.next()) { %>
            <table width="50%" bgcolor="#90ee90">
                <tr><td style="font-size:larger">Id</td></td><td style="font-size:larger"><%= result2.getLong("id")%></td></tr>
                <tr><td style="font-size:larger">LoaderKey</td><td style="font-size:larger"><a target="_blank" href="http://aus-lndssapp-02.wiley.com:8080/ui/#/activity_log/<%= result2.getLong("loaderKey")%>"><%= result2.getLong("loaderKey")%></a></td></tr>
                <tr><td style="font-size:larger">Size</td><td style="font-size:larger"><%= result2.getLong("packageSize")%></td></tr>
                <tr><td style="font-size:larger">Package</td><td style="font-size:larger"><%= result2.getString("remoteName")%></td></tr>
                <tr><td style="font-size:larger">CIID</td><td style="font-size:larger"><a target="_blank" href="content.jsp?contentItemId=<%= result2.getString("contentItemId")%>"><%= result2.getString("contentItemId")%></a></td></tr>
                <tr><td style="font-size:larger">LID</td><td style="font-size:larger"><%= result2.getLong("lid")%></td></tr>
                <tr><td style="font-size:larger">L.Name</td><td style="font-size:larger"><%= result2.getString("name")%></td></tr>
                <tr><td style="font-size:larger">Status</td><td style="font-size:larger"><%= result2.getString("stateCode")%></td></tr>
                <tr><td style="font-size:larger">Modified</td><td style="font-size:larger"><%= result2.getTimestamp("modifiedDateTime")%></td></tr>
                <tr><td style="font-size:larger" colspan="2"><a href="/resteasy/id/<%= result2.getString("contentItemId")%>/format/<%= result2.getLong("dfid")%>?fileDownload=true">Download Package</a></td></tr>
            </table>
            <br>
            <% } %>
        </td>
    </tr>
</table>

<%@ include file="footer.jsp" %>