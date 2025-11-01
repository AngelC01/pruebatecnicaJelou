export default function errorHandler(err, req, res, next) {
  console.error(err);
  if (err && err.code === 'ER_SIGNAL_EXCEPTION') {
    // MySQL SIGNAL used in stored procedures -> message in err.sqlMessage
    return res.status(400).json({ error: err.sqlMessage || 'Database error' });
  }
  const status = err.status || 500;
  res.status(status).json({ error: err.message || 'Internal Server Error' });
}
