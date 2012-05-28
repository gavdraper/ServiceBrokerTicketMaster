using System;
using System.Data;
using System.Data.SqlClient;

namespace BrokerLib
{
    public class Broker : IDisposable
    {
        SqlConnection con;
        SqlTransaction tran;
        SqlCommand cmd;

        public Broker(string connectionString)
        {
            con = new SqlConnection(connectionString);
            con.Open();
        }

        public void BeginTransaction()
        {
            if (tran != null)
                throw (new InvalidOperationException("Broker already has open transaction"));
            tran = con.BeginTransaction();
        }

        public void Rollback()
        {
            if(tran==null)
                throw(new InvalidOperationException("Broker not operating in a transactional context"));
            tran.Rollback();
            tran = null;
        }

        public void Commit()
        {
            if (tran == null)
                throw(new InvalidOperationException("Broker not operating in a transactional context"));
            tran.Commit();
            tran = null;
        }

        public void Send(Guid dialogHandle, string msg, string msgType)
        {
            SqlCommand cmd = con.CreateCommand();
            cmd.Transaction = tran;

            SqlParameter paramDialogHandle = new SqlParameter("@dh", SqlDbType.UniqueIdentifier);
            paramDialogHandle.Value = dialogHandle;
            cmd.Parameters.Add(paramDialogHandle);

            SqlParameter paramMsg = new SqlParameter("@msg", SqlDbType.NVarChar, msg.Length);
            paramMsg.Value = msg;
            cmd.Parameters.Add(paramMsg);

            cmd.CommandText = "SEND ON CONVERSATION @dh MESSAGE TYPE [" + msgType + "] (@msg)";

            cmd.ExecuteNonQuery();
        }

        public void Receive(string queueName, out string msgType, out string msg, out Guid ConversationGroup, out Guid dialogHandle)
        {
            msgType = null;
            msg = null;
            ConversationGroup = Guid.Empty;
            dialogHandle = Guid.Empty;

            cmd = con.CreateCommand();
            cmd.Transaction = tran;

            SqlParameter paramMsgType = new SqlParameter("@msgtype", SqlDbType.NVarChar, 256);
            paramMsgType.Direction = ParameterDirection.Output;
            cmd.Parameters.Add(paramMsgType);

            SqlParameter paramMsg = new SqlParameter("@msg", SqlDbType.NVarChar, 4000);
            paramMsg.Direction = ParameterDirection.Output;
            cmd.Parameters.Add(paramMsg);

            SqlParameter paramConversationGroup = new SqlParameter("@cg", SqlDbType.UniqueIdentifier);
            paramConversationGroup.Direction = ParameterDirection.Output;
            cmd.Parameters.Add(paramConversationGroup);

            SqlParameter paramDialogHandle = new SqlParameter("@dh", SqlDbType.UniqueIdentifier);
            paramDialogHandle.Direction = ParameterDirection.Output;
            cmd.Parameters.Add(paramDialogHandle);

            cmd.CommandText = "WAITFOR (RECEIVE TOP(1)  @msgtype = message_type_name, " +
                "@msg = message_body, " +
                "@cg = conversation_group_id, " +
                "@dh = conversation_handle " +
                "FROM [" + queueName + "]) " +
                ", TIMEOUT 5000";


            cmd.ExecuteNonQuery();

            if (!(paramMsgType.Value is DBNull))
            {
                msgType = (string)paramMsgType.Value;
                msg = (string)paramMsg.Value;
                ConversationGroup = (System.Guid)paramConversationGroup.Value;
                dialogHandle = (System.Guid)paramDialogHandle.Value;
            }
        }

        public void EndDialog(Guid dialogHandle)
        {
            SqlCommand cmd = con.CreateCommand();
            cmd.Transaction = tran;

            SqlParameter paramDialogHandle = new SqlParameter("@dh", SqlDbType.UniqueIdentifier);
            paramDialogHandle.Value = dialogHandle;
            cmd.Parameters.Add(paramDialogHandle);

            cmd.CommandText = "END CONVERSATION @dh ";

            cmd.ExecuteNonQuery();
        }

        private bool disposed;
        public void Dispose()
        {
            Dispose(true);
            GC.SuppressFinalize(this);
        }

        private void Dispose(bool disposing)
        {
            if (!this.disposed)
            {
                if (disposing)
                {
                    con.Dispose();
                }
                disposed = true;
            }
        }

    }
}
