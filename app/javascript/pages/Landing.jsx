import { Link } from '@inertiajs/react'
import { Text, Box } from '@mantine/core'

export default function Landing({ godFatherImageUrl, taxiDriverImageUrl }) {
  return (
    <Box
      style={{
        minHeight: '100vh',
        display: 'flex',
        flexDirection: 'row',
        background: '#080610',
      }}
    >
      {/* Left: Don portrait */}
      <Box
        style={{
          flex: '0 0 45%',
          position: 'relative',
          overflow: 'hidden',
        }}
      >
        <Box
          component="img"
          src={godFatherImageUrl}
          alt=""
          style={{
            position: 'absolute',
            inset: 0,
            width: '100%',
            height: '100%',
            objectFit: 'cover',
            objectPosition: 'center top',
            display: 'block',
          }}
        />
        {/* fade right edge into dark panel */}
        <Box
          style={{
            position: 'absolute',
            inset: 0,
            background: 'linear-gradient(to right, rgba(5,3,10,0.10) 40%, rgba(8,6,16,1) 100%)',
          }}
        />
        {/* subtle bottom vignette */}
        <Box
          style={{
            position: 'absolute',
            inset: 0,
            background: 'linear-gradient(to top, rgba(5,3,10,0.6) 0%, transparent 40%)',
          }}
        />
      </Box>

      {/* Right: report panel */}
      <Box
        style={{
          flex: 1,
          display: 'flex',
          flexDirection: 'column',
          justifyContent: 'center',
          padding: '60px 64px',
          gap: 36,
        }}
      >
        {/* Title block */}
        <Box>
          <Text
            style={{
              fontFamily: '"Cinzel", serif',
              fontSize: 10,
              letterSpacing: '0.3em',
              color: '#5A4E3A',
              textTransform: 'uppercase',
              marginBottom: 10,
            }}
          >
            Il Consiglio Privato
          </Text>
          <Text
            style={{
              fontFamily: '"Cinzel", serif',
              fontSize: 48,
              fontWeight: 700,
              color: '#C9A84C',
              letterSpacing: '0.08em',
              lineHeight: 1,
              textShadow: '0 2px 32px rgba(201,168,76,0.20)',
            }}
          >
            CONSIGLIERE
          </Text>
          <Text
            style={{
              fontFamily: '"EB Garamond", Georgia, serif',
              fontStyle: 'italic',
              fontSize: 17,
              color: '#5A4E3A',
              marginTop: 8,
              letterSpacing: '0.03em',
            }}
          >
            Vaša osobná spravodajská služba
          </Text>
        </Box>

        {/* Divider */}
        <Box style={{ height: 1, background: 'rgba(201,168,76,0.15)', maxWidth: 320 }} />

        {/* Operative report */}
        <Box style={{ display: 'flex', gap: 20, alignItems: 'flex-start' }}>
          {/* Avatar */}
          <Box
            style={{
              width: 72,
              height: 88,
              flexShrink: 0,
              overflow: 'hidden',
              border: '1px solid rgba(201,168,76,0.25)',
              filter: 'sepia(0.25) contrast(1.1)',
            }}
          >
            <Box
              component="img"
              src={taxiDriverImageUrl}
              alt="Agent"
              style={{
                width: '100%',
                height: '100%',
                objectFit: 'cover',
                objectPosition: 'top center',
                display: 'block',
              }}
            />
          </Box>

          {/* Report text */}
          <Box style={{ flex: 1 }}>
            <Text
              style={{
                fontFamily: '"Cinzel", serif',
                fontSize: 9,
                letterSpacing: '0.25em',
                color: '#5A4E3A',
                textTransform: 'uppercase',
                marginBottom: 10,
              }}
            >
              Hlásenie agenta
            </Text>
            <Text
              style={{
                fontFamily: '"EB Garamond", Georgia, serif',
                fontSize: 17,
                lineHeight: 1.75,
                color: '#DDD0B8',
              }}
            >
              Don, sledoval som súperné rodiny. Ich akcie,
              ich slabiny, ich pohyby — všetko zaznamenané.
            </Text>
          </Box>
        </Box>

        {/* Quote */}
        <Text
          style={{
            fontFamily: '"EB Garamond", Georgia, serif',
            fontStyle: 'italic',
            fontSize: 15,
            color: '#5A4E3A',
            lineHeight: 1.7,
            borderLeft: '2px solid rgba(201,168,76,0.20)',
            paddingLeft: 16,
            maxWidth: 380,
          }}
        >
          „Nechaj pištoľ. Vezmi cannoli."
          <br />
          <span style={{ fontSize: 13 }}>— a správy.</span>
        </Text>

        {/* CTA */}
        <Link
          href="/admin/competitor_monitoring/competitors"
          style={{ textDecoration: 'none', display: 'inline-block', alignSelf: 'flex-start' }}
        >
          <Box
            style={{
              background: '#C9A84C',
              color: '#0B0910',
              fontFamily: '"Cinzel", serif',
              fontSize: 11,
              fontWeight: 700,
              letterSpacing: '0.15em',
              textTransform: 'uppercase',
              padding: '13px 32px',
              cursor: 'pointer',
              transition: 'background 0.15s',
            }}
            onMouseEnter={e => { e.currentTarget.style.background = '#B8960C' }}
            onMouseLeave={e => { e.currentTarget.style.background = '#C9A84C' }}
          >
            Vstúpiť do pracovne
          </Box>
        </Link>

        {/* Bottom motto */}
        <Text
          style={{
            fontFamily: '"Cinzel", serif',
            fontSize: 9,
            letterSpacing: '0.3em',
            color: '#2A2018',
            textTransform: 'uppercase',
            marginTop: 'auto',
            paddingTop: 20,
          }}
        >
          Omertà · Lealtà · Rispetto
        </Text>
      </Box>
    </Box>
  )
}
