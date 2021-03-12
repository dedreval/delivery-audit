<%@ include file="header.jsp" %>
<%@ page import="java.sql.DriverManager" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.text.DateFormat" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%

    DateFormat DATE_FORMAT = new SimpleDateFormat("yyyy-MM-dd HH24");
    long licensefilter, formatfilter;
    try { formatfilter = Long.parseLong((String) request.getParameter("formatfilter")); } catch (Exception e) {formatfilter = -1;}
    try { licensefilter = Long.parseLong((String) request.getParameter("licensefilter")); } catch (Exception e) {licensefilter = -1;}
    long lid = request.getParameter("licenseId") == null ? -1 : Long.parseLong((String) request.getParameter("licenseId"));
    String ciid = (String) request.getParameter("contentItemId");
    int shift = request.getParameter("shift") == null ? 0 : Integer.parseInt((String) request.getParameter("shift"));

    String query = "SELECT pi.id, pi.packageSize, pi.contentItemId, l.id as \"lid\", l.name, pi.stateCode, pi.modifiedDateTime " +
            "FROM Push_Item pi, License l " +
            "WHERE pi.licenseId=l.id AND modifiedDateTime < SYSDATE - " + shift + "/24 " +
            "AND modifiedDateTime > SYSDATE - " + (shift + 1) + "/24 AND l.id in (" + allLicIds + ") AND initSource != 'BULK' ";

    if (licensefilter > 0) {
        query +="AND pi.licenseId=" + licensefilter + " ";
    }
    if (formatfilter > 0) {
        query +="AND l.deliveryFormatId=" + formatfilter + " ";
    }

    query +="ORDER BY modifiedDateTime";

    Class.forName("oracle.jdbc.driver.OracleDriver");
    String dbUrl = "jdbc:oracle:thin:@//CAR-LNDSSDBP-02.wiley.com:1593/DSSPROD";
    Connection conn = DriverManager.getConnection(dbUrl, "cdts", "cdts");
    PreparedStatement preparedStatement = conn.prepareStatement(query);
    ResultSet result = preparedStatement.executeQuery();

    String dbUrl2 = "jdbc:oracle:thin:@//AUS-LNDSSDBP-03.wiley.com:1593/DSSPRD";
    Connection conn2 = DriverManager.getConnection(dbUrl2, "DSS", "DSS");
    PreparedStatement preparedStatement2 = conn2.prepareStatement(query);
    ResultSet result2 = preparedStatement2.executeQuery();

    Date dateFrom = new Date (System.currentTimeMillis() + (shift * 3600 * 1000));
    Date dateTo = new Date (System.currentTimeMillis() + ((shift + 1) * 3600 * 1000));

    String dateFromStr = DATE_FORMAT.format(dateFrom);
    String dateToStr = DATE_FORMAT.format(dateTo);

%>
<table>
    <tr>
        <td colspan="3" align="left">
            <table width="0%">
                <form method="get">
                    <tr><td>Format Id</td><td><input name="formatfilter" value="<%=formatfilter%>" default="-1"></td></tr>
                    <tr><td>License Id</td><td><input name="licensefilter" value="<%=licensefilter%>" default="-1"></td></tr>
                    <tr><td>&nbsp;</td><td><input type="submit">&nbsp;<input type="reset" onclick='javascript:location.href="deliveries.jsp?licensefilter=-1&formatfilter=-1"'></td></tr>
                </form>
            </table>
        </td>
    </tr>
    <tr>
        <td colspan="3">
            Deliveries in a period from <%=dateFromStr%> to <%=dateToStr%>.
            <a href="?shift=<%=(shift + 1)%>&licensefilter=<%=licensefilter%>">Show previous hour delivery</a>.&nbsp;
            <a href="?shift=<%=(shift - 1)%>&licensefilter=<%=licensefilter%>">Show next hour delivery</a>.
        </td>
    </tr>
    <tr>
        <td><h1>Production server</h1></td>
        <td>&nbsp;</td>
        <td><h1>Pre-Production server</h1></td>
    </tr>
    <tr>
        <td valign="top">
            <table width="50%" bgcolor="#add8e6">
                <tr>
                    <th width="5%">Push Item ID</th>
                    <th width="30%">Content Item ID</th>
                    <th width="5%">License ID</th>
                    <th width="30%">License Name</th>
                    <th width="20%">Package Size, bytes</th>
                    <th width="5%">Status</th>
                    <th width="5%">&nbsp;</th>
                </tr>
                <% while (result.next()) { %>
                <tr>
                    <td><%= result.getLong("id")%></td>
                    <td><%= result.getString("contentItemId")%></td>
                    <td><%= result.getLong("lid")%></td>
                    <td><a href="deliveries.jsp?shift=<%=shift%>&licensefilter=<%=result.getLong("lid")%>"><%= result.getString("name")%></a></td>
                    <td><%= result.getLong("packageSize")%></td>
                    <td><%= result.getString("stateCode")%></td>
                    <td><%= result.getTimestamp("modifiedDateTime")%></td>
                    <td><a target="_blank" href="check.jsp?licenseId=<%= result.getLong("lid")%>&contentItemId=<%= result.getString("contentItemId")%>">check</a></td>
                </tr>
                <% } %>
            </table>
        </td>
        <td>&nbsp;&nbsp;</td>
        <td valign="top" bgcolor="#90ee90">
            <table width="50%">
                <tr>
                    <th width="5%">&nbsp;</th>
                    <th width="5%">Push Item ID</th>
                    <th width="30%">Content Item ID</th>
                    <th width="5%">License ID</th>
                    <th width="30%">License Name</th>
                    <th width="20%">Package Size, bytes</th>
                    <th width="5%">Status</th>
                </tr>
                <% while (result2.next()) { %>
                <tr>
                    <td><a target="_blank" href="check.jsp?licenseId=<%= result2.getLong("lid")%>&contentItemId=<%= result2.getString("contentItemId")%>">check</a></td>
                    <td><%= result2.getLong("id")%></td>
                    <td><%= result2.getString("contentItemId")%></td>
                    <td><%= result2.getLong("lid")%></td>
                    <td><a href="deliveries.jsp?shift=<%=shift%>&licensefilter=<%=result2.getLong("lid")%>"><%= result2.getString("name")%></a></td>
                    <td><%= result2.getLong("packageSize")%></td>
                    <td><%= result2.getString("stateCode")%></td>
                    <td><%= result2.getTimestamp("modifiedDateTime")%></td>
                </tr>
               <% } %>
            </table>
        </td>
    </tr>
</table>

<%@ include file="footer.jsp" %>

