#include "rwlock.h"

void InitalizeReadWriteLock(struct read_write_lock* rw)
{
  rw->num_of_readers = 0;
  rw->num_of_writers = 0;
  rw->writers_waiting = 0;
  pthread_cond_init(&rw->cond_read, NULL);
  pthread_cond_init(&rw->cond_write, NULL);
  pthread_mutex_init(&rw->lock, NULL);
  //	Write the code for initializing your read-write lock.
}

void ReaderLock(struct read_write_lock* rw)
{
  //	Write the code for aquiring read-write lock by the reader.
  pthread_mutex_lock(&rw->lock);
  while (rw->num_of_writers or rw->writers_waiting) {
    pthread_cond_wait(&rw->cond_read, &rw->lock);
  }
  rw->num_of_readers++;
  pthread_mutex_unlock(&rw->lock);
}

void ReaderUnlock(struct read_write_lock* rw)
{
  pthread_mutex_lock(&rw->lock);
  rw->num_of_readers--;
  if (rw->num_of_readers == 0)
    pthread_cond_signal(&rw->cond_write);
  pthread_mutex_unlock(&rw->lock);
}

void WriterLock(struct read_write_lock* rw)
{
  pthread_mutex_lock(&rw->lock);
  rw->writers_waiting++; 
  while (rw->num_of_readers or rw->num_of_writers) {
    pthread_cond_wait(&rw->cond_write, &rw->lock);
  }
  rw->num_of_writers = 1;
  rw->writers_waiting--;
  pthread_mutex_unlock(&rw->lock);

  //	Write the code for aquiring read-write lock by the writer.
}

void WriterUnlock(struct read_write_lock* rw)
{
  pthread_mutex_lock(&rw->lock);
  rw->num_of_writers = 0;
  if (rw->writers_waiting) {
    pthread_cond_signal(&rw->cond_write);
  }
  else {
    pthread_cond_broadcast(&rw->cond_read);
  }
  pthread_mutex_unlock(&rw->lock);
  //	Write the code for releasing read-write lock by the writer.
}
