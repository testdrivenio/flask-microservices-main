import { Selector } from 'testcafe';

const randomstring = require('randomstring');

const username = randomstring.generate();
const email = `${username}@test.com`;
const password = 'greaterthanten';
const currentDate = new Date();

const TEST_URL = process.env.TEST_URL;


fixture('/register').page(`${TEST_URL}/register`);

test(`should display the registration form`, async (t) => {
  await t
    .navigateTo(`${TEST_URL}/register`)
    .expect(Selector('H1').withText('Register').exists).ok()
    .expect(Selector('form').exists).ok()
    .expect(Selector('input[disabled]').exists).ok()
    .expect(Selector('.validation-list').exists).ok()
    .expect(Selector('.validation-list > .error').nth(0).withText(
      'Username must be greater than 5 characters.').exists).ok()
});

test(`should allow a user to register`, async (t) => {

  // register user
  await t
    .navigateTo(`${TEST_URL}/register`)
    .typeText('input[name="username"]', username)
    .typeText('input[name="email"]', email)
    .typeText('input[name="password"]', password)
    .click(Selector('input[type="submit"]'))

  // assert user is redirected to '/'
  // assert '/' is displayed properly
  const tableRow = Selector('td').withText(username).parent();
  await t
    .expect(Selector('H1').withText('All Users').exists).ok()
    .expect(tableRow.child().withText(username).exists).ok()
    .expect(tableRow.child().withText(email).exists).ok()
    .expect(Selector('a').withText('User Status').exists).ok()
    .expect(Selector('a').withText('Log Out').exists).ok()
    .expect(Selector('a').withText('Register').exists).notOk()
    .expect(Selector('a').withText('Log In').exists).notOk()

  // assert date is correct
  const createdDate = await tableRow.child('td').nth(3).innerText;
  const formattedDate = new Date(createdDate)
  await t
    .expect(currentDate.getUTCMonth()).eql(formattedDate.getUTCMonth())
    .expect(currentDate.getUTCDate()).eql(formattedDate.getUTCDate())
    .expect(
      currentDate.getUTCFullYear()).eql(formattedDate.getUTCFullYear())

});

test(`should throw an error if the username is taken`, async (t) => {

  // register user with duplicate user name
  await t
    .navigateTo(`${TEST_URL}/register`)
    .typeText('input[name="username"]', username)
    .typeText('input[name="email"]', `${email}unique`)
    .typeText('input[name="password"]', password)
    .click(Selector('input[type="submit"]'))

  // assert user registration failed
  await t
    .expect(Selector('H1').withText('Register').exists).ok()
    .expect(Selector('a').withText('User Status').exists).notOk()
    .expect(Selector('a').withText('Log Out').exists).notOk()
    .expect(Selector('a').withText('Register').exists).ok()
    .expect(Selector('a').withText('Log In').exists).ok()
    .expect(Selector('.alert-success').exists).notOk()
    .expect(Selector('.alert-danger').withText(
      'That user already exists.').exists).ok()

});

test(`should throw an error if the email is taken`, async (t) => {

  // register user with duplicate email
  await t
    .navigateTo(`${TEST_URL}/register`)
    .typeText('input[name="username"]', `${username}unique`)
    .typeText('input[name="email"]', email)
    .typeText('input[name="password"]', password)
    .click(Selector('input[type="submit"]'))

  // assert user registration failed
  await t
    .expect(Selector('H1').withText('Register').exists).ok()
    .expect(Selector('a').withText('User Status').exists).notOk()
    .expect(Selector('a').withText('Log Out').exists).notOk()
    .expect(Selector('a').withText('Register').exists).ok()
    .expect(Selector('a').withText('Log In').exists).ok()
    .expect(Selector('.alert-success').exists).notOk()
    .expect(Selector('.alert-danger').withText(
      'That user already exists.').exists).ok()

});
